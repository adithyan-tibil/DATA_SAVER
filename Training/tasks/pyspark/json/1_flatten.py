from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, ArrayType

# Initialize Spark session
spark = SparkSession.builder.appName("NestedJSONExample").getOrCreate()

# Define the schema
schema = StructType([
    StructField("id", IntegerType(), True),
    StructField("name", StringType(), True),
    StructField("address", StructType([
        StructField("street", StringType(), True),
        StructField("city", StringType(), True),
        StructField("state", StringType(), True)
    ]), True),
    StructField("courses", ArrayType(StructType([
        StructField("name", StringType(), True),
        StructField("grade", StringType(), True)
    ])), True)
])

# Path to the JSON file
file_path = "data.json"

# Read JSON file into DataFrame
df = spark.read.json(file_path, schema=schema)

# Show the DataFrame
df.show(truncate=False)
df.printSchema()
