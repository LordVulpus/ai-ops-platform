import logging
import os
import time
import json
import numpy as np
from forecast import run_forecast
from datetime import datetime
from fastapi import FastAPI, Header, HTTPException
from sklearn.ensemble import IsolationForest
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Histogram, Gauge
from azure.storage.blob import BlobServiceClient

#Azure Storage Config
BLOB_CONN_STR = os.getenv("BLOB_CONNECTION_STRING")
CONTAINER_NAME = "jfblob1"
BUFFER_THRESHOLD = 50
telemetry_upload_buffer = []

#Initialise Blob client only if connection string exists
blob_service = None
if BLOB_CONN_STR:
    blob_service = BlobServiceClient.from_connection_string(BLOB_CONN_STR)

# Add telemetry history
telemetry_history = []
# Setup Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialise ML Model
model = IsolationForest(contamination=0.2)
app = FastAPI()

Instrumentator().instrument(app).expose(app)

# Environment Variables - Ensure this matches your K8s Secret/ConfigMap
API_KEY = os.getenv("API_KEY")

# Custom Prometheus Metrics
prediction_counter = Counter("aiops_predictions_total", "Total predictions")
anomalies_detected = Counter("anomalies_detected_total", "Total anomalies")
prediction_latency = Histogram("prediction_latency_seconds", "ML model latency")
forecast_requests_total = Counter("aiops_forecast_requests_total", "Total forecast requests")
forecast_latency_seconds = Histogram("aiops_forecast_latency_seconds", "Forecast latency")
cpu_forecast = Gauge("aiops_cpu_forecast", "Predicted CPU value")
prediction_error = Gauge("aiops_prediction_error", "Difference between predicted and actual values")

def upload_to_azure(buffer_data):
    """Handles the actual batch upload to Azure"""
    if not blob_service
        logger.error("Azure Blob Service not initialized. Check connection string.")
        return
    try:
        blob_name = f"telemetry-batch-{int(time.time())}.json"
        blob_client = blob_service.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
        blob_client.upload_blob(json.dumps(buffer_data), overwrite=True)
        logger.info(f"Batch upload successful: {blob_name}")
    except Exception as e:
        logger.error(f"Azure Upload Failed: {e}")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/forecast")
def forecast():
    forecast_requests_total.inc()

    if len(telemetry_history) < 20:
        return {"error": "Not enough data"}

    data = prepare_forecast_data()
    with forecast_latency_seconds.time():
        result = run_forecast(data)

    if result.empty:
        return {"error": "Forecast produced no results"}

    # Fix: Cast numpy float to python float for JSON compatibility
    latest_prediction = float(result.iloc[-1]["yhat"])
    cpu_forecast.set(latest_prediction)

    return result.to_dict(orient="records")

@app.post("/predict")
async def predict(data: dict, x_api_key: str = Header(None, alias="x-api-key")):
    global telemetry_upload_buffer
 # Security Check
    if not API_KEY or x_api_key != API_KEY:
        logger.warning("Unauthorized access attempt.")
        raise HTTPException(status_code=403, detail="Forbidden or missing API Key")

    values = data.get("values", [])
    if not values or not isinstance(values, list):
        raise HTTPException(status_code=400, detail="Payload must contain a 'values' list")

    prediction_counter.inc()
    logger.info(f"Processing {len(values)} data points")

    try:
        anomalies = detect(values)
        if anomalies:
            anomalies_detected.inc(len(anomalies))


        # This compares the FIRST incoming value to the LAST predicted CPU value
        current_actual = values[0]
        predicted_val = cpu_forecast._value.get()

        if predicted_val != 0: # Ensure we actually have a prediction to compare against
            error = abs(current_actual - predicted_val)
            prediction_error.set(error)

        telemetry_entry = {
            "timestamp": time.time(),
            "input_values": values,
            "anomalies_found": anomalies,
            "count": len(anomalies)
        }
        telemetry_upload_buffer.append(telemetry_entry)

        # Triggers upload if buffer is full
        if len(telemetry_upload_buffer) >= BUFFER_THRESHOLD:
            upload_to_azure(telemetry_upload_buffer)
            telemetry_upload_buffer = []

        # Better Telemetry Management: Append all values if they represent points in time
        for val in values:
            telemetry_history.append({"timestamp": time.time(), "cpu": val})

        # Keep history window manageable
        if len(telemetry_history) > 1000:
            del telemetry_history[:len(values)]

        return {
            "status": "success",
                        "data_points_processed": len(values),
            "anomalies_found": len(anomalies),
            "anomalies": anomalies,
                        "prediction": "success"
        }

    except Exception as e:
        logger.error(f"ML Model Error: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal ML processing error")

def detect(values):
    with prediction_latency.time():
        if len(telemetry_history) < 20:
            logger.info("Not enough history for baseline; skipping detection.")
            return []

        historical_values = [item["cpu"] for item in telemetry_history]
        X_train = np.array(historical_values).reshape(-1, 1)

        # Refit on the fly (Warning: Slow if history is large)
        model.fit(X_train)

        X_test = np.array(values).reshape(-1, 1)
        preds = model.predict(X_test)

        return [float(v) for v, p in zip(values, preds) if p == -1]

def prepare_forecast_data():
    return [{"ds": datetime.fromtimestamp(e["timestamp"]), "y": e["cpu"]} for e in telemetry_history]
