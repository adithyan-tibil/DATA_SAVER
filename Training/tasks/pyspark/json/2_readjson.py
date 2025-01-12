# Read the Dataframe_Sql Json file and remove the duplicates.

from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()

df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

dupli=df.dropDuplicates()

dupli.show()
df.show()