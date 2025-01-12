from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()

df = spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

# df.select('title','author','rank','price').show()

df['title', 'author', 'rank', 'price'].show()
