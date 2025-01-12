from pyspark.sql import SparkSession

# Create a Spark session
spark = SparkSession.builder \
    .appName("TextToJsonStreaming") \
    .getOrCreate()

# Define input and output paths
input_path = 'sample1/input'
output_path = 'sample1/output'

# Create a streaming DataFrame that monitors the input folder
df = spark.readStream \
    .format("text") \
    .load(input_path)  # Load text files from the input path

# Write the streaming DataFrame to JSON format (without filename)
query = df.writeStream \
    .format("json") \
    .outputMode("append") \
    .option("checkpointLocation", "sample1/checkpoint") \
    .option("path", output_path) \
    .start()

# Keep the application running
try:
    print("Streaming started. Waiting for new files...")
    query.awaitTermination()
except KeyboardInterrupt:
    print("Stopping the streaming application...")
finally:
    query.stop()
    spark.stop()
