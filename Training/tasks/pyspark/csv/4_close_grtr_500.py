from pyspark.sql import SparkSession

spark=SparkSession.builder.appName('closegrtr500').getOrCreate()

csv_file=spark.read.csv('/home/aditya/adithyan/Training/tasks/pyspark/data/Apple-stock-csv-data.csv',header=True,inferSchema=True)

# view=csv_file.createTempView('BOOM')
# read_view=spark.sql('SELECT * FROM BOOM WHERE CLOSE > 500')

read_view=csv_file.filter(csv_file.Close > 500)

read_view.show()