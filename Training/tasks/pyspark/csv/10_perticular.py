from pyspark.sql import SparkSession


spark = SparkSession.builder.appName('read_csv').getOrCreate()

csv_file = spark.read.csv('/home/aditya/adithyan/Training/tasks/pyspark/data/Apple-stock-csv-data.csv',
                          inferSchema=True, header=True)

# view=csv_file.createTempView('sample')
# particular=spark.sql('SELECT DATE,OPEN FROM SAMPLE')

# particular=csv_file['Open','Date']

particular = csv_file.select('Open', 'Date')

particular.show()
print(spark.sparkContext.appName)

