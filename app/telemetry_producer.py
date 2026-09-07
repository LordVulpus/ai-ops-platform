import json
import random
import time
import os
import numpy as np # Added missing numpy import for the sine wave!
from azure.eventhub import EventHubProducerClient, EventData
from azure.identity import DefaultAzureCredential # Added for Managed Identity

# Event Hub Configurations
EVENTHUB_NAMESPACE_URL = "jfaiops-eventhub.servicebus.windows.net" 
EVENTHUB_NAME = "telemetry-hub"

# Initialise Producer Client seamlessly using Managed Identity
try:
    credential = DefaultAzureCredential()
    producer = EventHubProducerClient(
        fully_qualified_namespace=EVENTHUB_NAMESPACE_URL,
        eventhub_name=EVENTHUB_NAME,
        credential=credential
    )
    print("Successfully initialized Event Hub Producer via DefaultAzureCredential")
except Exception as e:
    producer = None
    print(f"Failed to initialize Event Hub Producer with Managed Identity: {e}")

while True:
    if not producer:
        print("Producer client not available. Sleeping...")
        time.sleep(5)
        continue

    # Simulates smooth background load with a sine wave
    cpu_value = 50 + 20 * np.sin(time.time() / 600)

    # 5% chance to inject an artificial spike anomaly
    if random.random() < 0.05:
        cpu_value += 40

    telemetry = {
        "cpu": round(cpu_value, 2),
        "memory": random.randint(40, 90),
        "latency": random.randint(5, 50)
    }

    try:
        event_data_batch = producer.create_batch()
        event_data_batch.add(EventData(json.dumps(telemetry)))
        producer.send_batch(event_data_batch)
        print("Sent:", telemetry)
    except Exception as e:
        print(f"Error sending to Event Hub: {e}")
        
    time.sleep(5)

