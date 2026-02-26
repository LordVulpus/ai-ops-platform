import logging
from fastapi import FastAPI
from model import detect_anomaly

logging.basicConfig(level=logging.INFO)

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(data: dict):
    logging.info(f"Received data: {data}")
    values = data.get("values", [])
    anomalies = detect_anomaly(values)
    return {"anomalies": anomalies}
