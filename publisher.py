import paho.mqtt.client as mqtt
import time

broker = "BrokerAdressHere"
port = #port here
topic = "TopicNameHere"

client = mqtt.Client()
client.connect(broker, port, 60)

client.loop_start()

for i in range(5):
    message = f"Mesaj {i}"
    client.publish(topic, message)
    print("Gönderildi:", message)
    time.sleep(2)

client.loop_stop()
client.disconnect()