# Counts the number of distinct rows in dataframe
from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()

df = spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

distinct_row=df.distinct()

print(df.count())
print(distinct_row.count())
