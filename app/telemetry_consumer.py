import json
import requests
import os
from azure.eventhub import EventHubConsumerClient
CONNECTION_STR = os.getenv("EVENTHUB_CONNECTION_STR")
EVENTHUB_NAME = "telemetry-hub"
API_ENDPOINT = "http://51.104.40.79/predict"
API_KEY = os.getenv("API_KEY")

if not API_KEY:
    raise ValueError("API_KEY environment variable is not set!")

def on_event(partition_context, event):
   telemetry = json.loads(event.body_as_str())
   values = [
       telemetry["cpu"],
       telemetry["memory"],
       telemetry["latency"]
   ]
   r = requests.post(
       API_ENDPOINT,
       headers={
           "x-api-key": API_KEY
       },
       json={"values": values}
   )
   print("Prediction:", r.json())

client = EventHubConsumerClient.from_connection_string(
   CONNECTION_STR,
   consumer_group="$Default",
   eventhub_name=EVENTHUB_NAME
)
with client:
   client.receive(
       on_event=on_event,
       starting_position="-1"
)
