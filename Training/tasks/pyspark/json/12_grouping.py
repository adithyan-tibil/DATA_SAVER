# Group by author, count the books of the authors in the groups

from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()


df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

grouped=df.groupBy('author').count()

grouped.show()