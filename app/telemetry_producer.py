import json
import random
import time
import os
from azure.eventhub import EventHubProducerClient, EventData
CONNECTION_STR = os.getenv("EVENTHUB_CONNECTION_STR")
EVENTHUB_NAME = "telemetry-hub"
producer = EventHubProducerClient.from_connection_string(
   conn_str=CONNECTION_STR,
   eventhub_name=EVENTHUB_NAME
)
while True:

   cpu_value = 50 + 20 * np.sin(time.time() / 600)

   if random.random() < 0.05:
       cpu_value += 40

   telemetry = {
       "cpu": round(cpu_value, 2),
       "memory": random.randint(40,90),
       "latency": random.randint(5,50)
   }

   try:
      event_data_batch = producer.create_batch()
      event_data_batch.add(EventData(json.dumps(telemetry)))
      producer.send_batch(event_data_batch)
      print("Sent:", telemetry)
      except Exception as e:
       print(f"Error sending to Event Hub: {e}")
   time.sleep(5)
