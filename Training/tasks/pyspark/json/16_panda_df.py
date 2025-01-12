from pyspark.sql import *

spark = SparkSession.builder.appName('df_to_rddstr').getOrCreate()

data = [
    (1, "THE Great Gatsby", "F. Scott Fitzgerald", 1925),
    (2, "The Catcher in the Rye", "J.D. Salinger", 1951),
    (3, "The Lord of the Rings", "J.R.R. Tolkien", 1954),
    (4, "1984", "George Orwell", 1949),
    (5, "Brave New World", "Aldous Huxley", 1932),
    (6, "To Kill a Mockingbird", "Harper Lee", 1960),
    (7, "The Hobbit", "J.R.R. Tolkien", 1937),
    (8, "Fahrenheit 451", "Ray Bradbury", 1953),
    (9, "The Great Adventures", "Someone Else", 2000),
    (10, "THE Unknown Title", "Unknown Author", 2021)
]
columns = ["id", "title", "author", "year"]

sparkDf = spark.createDataFrame(data, columns)

pandaDF=sparkDf.toPandas()

sparkDf.show()

print(pandaDF)


