import logging
import os
import time
import numpy as np
from forecast import run_forecast
from datetime import datetime
from fastapi import FastAPI, Header, HTTPException
from sklearn.ensemble import IsolationForest
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Histogram, Gauge

#Add telemetry history
telemetry_history = []
# Setup Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialise ML Model
model = IsolationForest(contamination=0.2)
app = FastAPI()

Instrumentator().instrument(app).expose(app)

# Environment Variables
API_KEY = os.getenv("API_KEY")

# Custom Prometheus Metrics
prediction_counter = Counter(
    "aiops_predictions_total",
    "Total number of AI predictions processed")

anomalies_detected = Counter(
    "anomalies_detected_total",
    "Total anomalies detected by the model")

prediction_latency = Histogram(
    "prediction_latency_seconds",
    "Time spent running the ML model")

forecast_requests_total = Counter(
   "aiops_forecast_requests_total",
   "Total forecasting requests")

forecast_latency_seconds = Histogram(
   "aiops_forecast_latency_seconds",
   "Forecast model runtime")

cpu_forecast = Gauge(
   "aiops_cpu_forecast",
   "Predicted CPU value")

prediction_error = Gauge(
   "aiops_prediction_error",
   "Difference between predicted and actual values")

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
   latest_prediction = result.iloc[-1]["yhat"]
   cpu_forecast.set(latest_prediction)
   return result.to_dict(orient="records")

@app.post("/predict")
async def predict(data: dict, x_api_key: str = Header(None)):
    # Check Security
    if not API_KEY or x_api_key != API_KEY:
        logger.warning("Unauthorized access attempt.")
        raise HTTPException(status_code=403, detail="Forbidden or missing API Key")

    values = data.get("values", [])

    if not values or not isinstance(values, list):
        raise HTTPException(status_code=400, detail="Payload must contain a 'values' list")

    prediction_counter.inc()
    logger.info(f"Processing {len(values)} data points")

    try:
        # Internal error handling
        anomalies = detect(values)
        # Increment anomaly counter
        if anomalies:
            anomalies_detected.inc(len(anomalies))

        telemetry_history.append({
        "timestamp": time.time(),
        "cpu": values[0]})

        if len(telemetry_history) > 1000:
            telemetry_history.pop(0)

        return {
            "status": "success",
            "data_points_processed": len(values),
            "anomalies_found": len(anomalies),
            "anomalies": anomalies,
            "prediction": "success"}

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

        # 3. Fit model on HISTORY
        if len(historical_values) > 20:
	    model.fit(X_train)

        # 4. Predict on NEW values
        X_test = np.array(values).reshape(-1, 1)
        preds = model.predict(X_test) # -1 is anomaly, 1 is normal

        # 5. Extract anomalies
        anomalies = [float(v) for v, p in zip(values, preds) if p == -1]
        return anomalies

def prepare_forecast_data():
   data = []
   for entry in telemetry_history:
       data.append({
           "ds": datetime.fromtimestamp(entry["timestamp"]),
           "y": entry["cpu"]
       })
   return data
