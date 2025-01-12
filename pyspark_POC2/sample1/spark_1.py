from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("TextToJsonStreaming") \
    .getOrCreate()

input_path = 'sample1/input'
output_path = 'sample1/output'

df = spark.readStream \
    .format("text") \
    .load(input_path)  

query = df.writeStream \
    .format("json") \
    .outputMode("append") \
    .option("checkpointLocation", "sample1/checkpoint") \
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
