import os
import psycopg2
from faker import Faker

def store_update_queries_to_file(num_rows):
    filename = '/home/aditya/adithyan/TIBIL_GIT/DATA_SAVER/python_dummydata_DMS/datastore/queries.txt'


    fake = Faker()

    with open(filename, 'w') as f:
        # Loop to generate the update queries
        for i in range(num_rows):
            vid = i + 45001
            mid = i + 45001
            brid = 10
            bid = 1
            did = i + 45001

            # Directly format the values into the query string
            query = f"""
            UPDATE registry.sb
            SET mid = {mid}, brid = {brid}, bid = {bid} , vid = {vid}
            WHERE did = {did};
            """
            f.write(query + "\n")

store_update_queries_to_file(5000)
