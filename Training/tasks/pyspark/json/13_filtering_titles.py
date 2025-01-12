# Filtering entries of title, Only keeps records having value 'THE HOST'.

from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()

df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

filtered=df.filter(df['title'].contains('THE HOST'))

filtered.show()