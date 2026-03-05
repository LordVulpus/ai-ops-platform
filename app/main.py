import logging
import os
import numpy as np
from fastapi import FastAPI, Header, HTTPException
from sklearn.ensemble import IsolationForest
from model import detect, detect_anomaly
from prometheus_fastapi_instrumentator import Instrumentator

logging.basicConfig(level=logging.INFO)
model = IsolationForest(contamination=0.2)
app = FastAPI()
Instrumentator().instrument(app).expose(app)
API_KEY = os.getenv("API_Key")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(data: dict, x_api_key: str = Header(None)):
	# Check Security
	if x_api_key != API_KEY:
		raise HTTPException(status_code=403, detail="Forbidden")

	logging.info(f"Received data: {data}")
	values = data.get("values", [])

	if not values:
		return {"error": "No values provided"}

	logging.info(f"Values extracted: {values}")

	anomalies = detect(values)
	return {"anomalies": anomalies}

def detect(values):
	X = np.array(values).reshape(-1, 1)
	preds = model.fit_predict(X)
	anomalies = [v for v, p in zip(values, preds) if p == -1]
	return anomalies
