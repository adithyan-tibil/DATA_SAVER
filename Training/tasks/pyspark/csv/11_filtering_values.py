from pyspark.sql import SparkSession

spark=SparkSession.builder.appName('read_csv').getOrCreate()

csv_file=spark.read.csv('/home/aditya/adithyan/Training/tasks/pyspark/data/Apple-stock-csv-data.csv',inferSchema=True,header=True)

filtered=csv_file.filter(csv_file.Open>600)

filtered.show()