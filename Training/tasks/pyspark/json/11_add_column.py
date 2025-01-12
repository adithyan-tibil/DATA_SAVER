# Add a column name as ‘new_column’ and give the value ‘This is a new column’
# Update column name 'amazon_product_url' with 'URL'
# Remove column ‘new_column’ from the DF.

from pyspark.sql import *

from pyspark.sql.functions import *

spark = SparkSession.builder.appName('json').getOrCreate()


df=spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')


new_df=df.withColumn('new_column',lit('This is a new column'))
new_df2=new_df.drop('new_column')
url_column=df.withColumnRenamed('amazon_product_url','url')

url_column.show()