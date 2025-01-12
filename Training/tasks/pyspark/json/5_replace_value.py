from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()

df = spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

replaced = df.replace('Harper', 'Kelappan')

replaced.show()
