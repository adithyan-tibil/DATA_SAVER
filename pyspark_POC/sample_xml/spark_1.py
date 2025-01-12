from pyspark.sql import SparkSession

# Create a Spark session with the XML package
spark = SparkSession.builder \
    .appName("XMLToJsonStreaming") \
    .getOrCreate()

# Define input and output paths
input_path = 'sample_xml/input'  # Folder containing XML files
output_path = 'sample_xml/output'  # Folder for JSON output

# Read XML files as a streaming DataFrame
df = spark.readStream \
    .format("com.databricks.spark.xml") \
    .option("rowTag", "root") \
    .load(input_path)

# Write the streaming DataFrame to JSON format
query = df.writeStream \
    .format("json") \
    .outputMode("append") \
    .option("checkpointLocation", "sample_xml/checkpoint") \
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
