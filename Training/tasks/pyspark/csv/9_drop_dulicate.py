from pyspark.sql import SparkSession

spark=SparkSession.builder.appName('read_csv').getOrCreate()

df=spark.read.csv('/home/aditya/adithyan/Training/tasks/pyspark/data/Apple-stock-csv-data.csv',inferSchema=True,header=True)

# csv_file=[('Alice','dd'),('bam','nn'),('Alice','dd')]
# df=spark.createDataFrame(csv_file)
# droped=df.dropDuplicates()

droped=df.dropDuplicates()

# droped.show()
print(df.count())
print(droped.count())
