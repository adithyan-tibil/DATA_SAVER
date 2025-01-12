from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder \
    .appName("XML to JSON Streaming") \
    .getOrCreate()

# Input and output paths
input_path = 'path/to/input/xml'
output_path = 'path/to/output/json'

# Read the XML stream
df = spark.readStream \
    .format("xml") \
    .option("rowTag", "person") \
    .load(input_path)

# Write the stream as JSON
query = df.writeStream \
    .format("json") \
    .outputMode("append") \
    .option("checkpointLocation", "path/to/checkpoint") \
    .option("path", output_path) \
    .start()

query.awaitTermination()