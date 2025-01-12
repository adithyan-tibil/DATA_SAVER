# Show author and title is TRUE if title has " THE " word in titles

from pyspark.sql import *
from pyspark.sql.functions import *

spark = SparkSession.builder.appName('json').getOrCreate()


df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

##Show author and title is TRUE if title has " THE " word in titles
# data=df.withColumn('author', when(col('title').contains('THE'), True).otherwise(False)).withColumn('title', when(col('title').contains('THE'), True).otherwise(False))

# # Show author and title is TRUE if the title starts with " THE " word.
# data=df.withColumn('author', when(col('title').startswith('THE'), True).otherwise(False)).withColumn('title', when(col('title').startswith('THE'), True).otherwise(False))

# Show author and title is TRUE if title ends with " THE " word
data=df.withColumn('author', when(col('title').endswith('THE'), True).otherwise(False)).withColumn('title', when(col('title').endswith('THE'), True).otherwise(False))


data.show()
