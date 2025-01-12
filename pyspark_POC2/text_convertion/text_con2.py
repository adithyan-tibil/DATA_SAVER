from Crypto.Cipher import AES
import base64
import requests
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf, col
from pyspark.sql.types import StringType

def decrypt_content(encrypted_data_b64):
    algorithm = 'aes-256-gcm'
    secret_key = b'k92ldahavl97s428vxri7x89seoy79sm'
    init_vector = b'7dzhcnrb0016hmj3'

    encrypted_data = base64.b64decode(encrypted_data_b64)
    auth_tag = encrypted_data[-16:]
    ciphertext = encrypted_data[:-16]

    cipher = AES.new(secret_key, AES.MODE_GCM, nonce=init_vector)
    decrypted = cipher.decrypt_and_verify(ciphertext, auth_tag)

    return decrypted.decode('utf-8')

def send_to_api(json_data):
    url = "http://localhost:5000/store"
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.post(url, json=json_data, headers=headers)
        response.raise_for_status()
        print(f"Data sent successfully: {json_data}")
    except requests.exceptions.RequestException as e:
        print(f"Error sending data to API: {e}")

spark = SparkSession.builder \
    .appName("TextToJsonStreaming") \
    .getOrCreate()

input_path = '/home/aditya/adithyan/pyspark_POC/text_convertion/input'

decrypt_udf = udf(decrypt_content, StringType())

df = spark.readStream \
    .format("text") \
    .load(input_path)

decrypted_df = df.select(decrypt_udf(col("value")).alias("decrypted_value"))
final_df = decrypted_df.selectExpr("decrypted_value as value")

def send_json_data_to_api(batch_df, batch_id):
    for row in batch_df.collect():
        json_data = {"value": row['value']}
        send_to_api(json_data)

query = final_df.writeStream \
    .foreachBatch(send_json_data_to_api) \
    .outputMode("append") \
    .start()

try:
    print("Streaming started. Waiting for new files...")
    query.awaitTermination()
except KeyboardInterrupt:
    print("Stopping the streaming application...")
finally:
    query.stop()
    spark.stop()
