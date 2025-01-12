from Crypto.Cipher import AES
import base64
import os
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

spark = SparkSession.builder \
    .appName("TextToJsonStreaming") \
    .getOrCreate()

input_path = '/home/aditya/adithyan/pyspark_POC/text_convertion/input'
output_path = '/home/aditya/adithyan/pyspark_POC/text_convertion/output'

decrypt_udf = udf(decrypt_content, StringType())

df = spark.readStream \
    .format("text") \
    .load(input_path)

decrypted_df = df.select(decrypt_udf(col("value")).alias("decrypted_value"))
final_df = decrypted_df.selectExpr("decrypted_value as value")

query = final_df.writeStream \
    .format("json") \
    .outputMode("append") \
    .option("checkpointLocation", "/home/aditya/adithyan/pyspark_POC/text_convertion/checkpoint") \
    .option("path", output_path) \
    .start()

try:
    print("Streaming started. Waiting for new files...")
    query.awaitTermination()
except KeyboardInterrupt:
    print("Stopping the streaming application...")
finally:
    query.stop()
    spark.stop()
