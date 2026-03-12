import json
import random
import time
from azure.eventhub import EventHubProducerClient, EventData
CONNECTION_STR = os.getenv("EVENTHUB_CONNECTION_STR")
EVENTHUB_NAME = "telemetry-hub"
producer = EventHubProducerClient.from_connection_string(
   conn_str=CONNECTION_STR,
   eventhub_name=EVENTHUB_NAME
)
while True:
   telemetry = {
       "cpu": random.randint(20,80),
       "memory": random.randint(40,90),
       "latency": random.randint(5,50)
   }
   event_data_batch = producer.create_batch()
   event_data_batch.add(EventData(json.dumps(telemetry)))
   producer.send_batch(event_data_batch)
   print("Sent:", telemetry)
   time.sleep(5)
