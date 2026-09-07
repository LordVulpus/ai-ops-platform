import json
import requests
import os
from azure.eventhub import EventHubConsumerClient
from azure.identity import DefaultAzureCredential # Added for Managed Identity

# Event Hub & Endpoint Configurations
EVENTHUB_NAMESPACE_URL = "jfaiops-eventhub.servicebus.windows.net" # Points directly to your namespace FQDN
EVENTHUB_NAME = "telemetry-hub"
API_ENDPOINT = "http://51.104.40.79/predict"
API_KEY = os.getenv("API_KEY")

if not API_KEY:
    raise ValueError("API_KEY environment variable is not set!")

def on_event(partition_context, event):
    try:
        telemetry = json.loads(event.body_as_str())
        values = [
            telemetry["cpu"],
            telemetry["memory"],
            telemetry["latency"]
        ]
        r = requests.post(
            API_ENDPOINT,
            headers={"x-api-key": API_KEY},
            json={"values": values}
        )
        print("Prediction:", r.json())
    except Exception as e:
        print(f"Error processing event: {e}")

# Initialise Consumer Client seamlessly using Managed Identity
try:
    credential = DefaultAzureCredential()
    client = EventHubConsumerClient(
        fully_qualified_namespace=EVENTHUB_NAMESPACE_URL,
        eventhub_name=EVENTHUB_NAME,
        consumer_group="$Default",
        credential=credential
    )
    print("Successfully initialized Event Hub Consumer via DefaultAzureCredential")
except Exception as e:
    client = None
    print(f"Failed to initialize Event Hub Consumer with Managed Identity: {e}")

if client:
    with client:
        client.receive(
            on_event=on_event,
            starting_position="-1"
        )

