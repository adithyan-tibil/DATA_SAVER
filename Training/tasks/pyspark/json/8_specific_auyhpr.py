from pyspark.sql import *
from pyspark.sql.functions import *

spark = SparkSession.builder.appName('json').getOrCreate()


df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

# df.filter('author in ("John Sandford", "Emily Giffin")').show()
df.filter(col('author').isin("John Sandford", "Emily Giffin")).show()
