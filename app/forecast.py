import pandas as pd
from prophet import Prophet

def run_forecast(history):

	df = pd.DataFrame(history)
	df.columns = ["ds", "y"]
	model = Prophet()
	model.fit(df)
	future = model.make_future_dataframe(periods=10, freq="min")
	forecast = model.predict(future)
	predictions = forecast[["ds","yhat"]].tail(10)
	return predictions
