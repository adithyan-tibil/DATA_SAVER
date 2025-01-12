from pyspark.sql import SparkSession

spark=SparkSession.builder.appName('sql_return_df').getOrCreate()

csv_file=spark.read.csv('/home/aditya/adithyan/Training/tasks/pyspark/data/Apple-stock-csv-data.csv',header=True,inferSchema=True)

view=csv_file.createTempView('SAMPLE')

read_view=spark.sql('SELECT * FROM SAMPLE WHERE LIMIT 10')

read_view.show()