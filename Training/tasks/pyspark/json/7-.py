from pyspark.sql import *
from pyspark.sql.functions import *

spark = SparkSession.builder.appName('json').getOrCreate()


df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')


data=df.withColumn('', when(col('title').isNotNull(), 1).otherwise(0))

data.show()
