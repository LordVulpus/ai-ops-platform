from fastapi import FastAPI
from model import detect_anomaly

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(data: dict):
    values = data.get("values", [])
    anomalies = detect_anomaly(values)
    return {"anomalies": anomalies}

