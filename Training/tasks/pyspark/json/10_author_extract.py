# Select author extracted the text between (1,3),(3,6) and (1,6) & gave column names as title 1, title 2 and title 3
from pyspark.sql import *

spark = SparkSession.builder.appName('json').getOrCreate()

df = spark.read.json('/home/aditya/adithyan/Training/tasks/pyspark/data/Dataframe_sql.json')

view=df.createTempView('autho')

data=spark.sql('SELECT SUBSTR(AUTHOR,1,3) AS TITLE_1,SUBSTR(AUTHOR,3,6) AS TITLE_2,SUBSTR(AUTHOR,1,6) AS TITLE_3 FROM AUTHO ')

data.show()