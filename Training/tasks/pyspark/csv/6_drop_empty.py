from pyspark.sql import SparkSession

spark=SparkSession.builder.appName('read_csv').getOrCreate()

csv_file=spark.read.csv('/home/aditya/adithyan/Training/tasks/pyspark/data/Apple-stock-csv-data.csv',inferSchema=True,header=True)

df=csv_file.dropna()

df.show(n=10)