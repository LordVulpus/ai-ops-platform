import logging
import os
import numpy as np
from fastapi import FastAPI, Header, HTTPException
from sklearn.ensemble import IsolationForest
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Histogram

# Setup Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialise ML Model
model = IsolationForest(contamination=0.2)
app = FastAPI()

@app.on_event("startup")
async def expose_metrics():
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

@app.get("/health")
def health():
    return {"status": "ok"}

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
        X = np.array(values).reshape(-1, 1)
        if len(X) < 2:
            return []
        model.fit(X)  # Added fit before predict to ensure it works
        preds = model.predict(X)
        anomalies = [float(v) for v, p in zip(values, preds) if p == -1]
        return anomalies

