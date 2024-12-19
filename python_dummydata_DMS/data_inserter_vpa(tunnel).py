import os
import psycopg2
from faker import Faker

def store_queries_to_file(num_rows):
    filename = '/home/aditya/adithyan/TIBIL_GIT/DATA_SAVER/python_dummydata_DMS/datastore/queries.txt'

    fake = Faker()
    bid_list = [1]

    with open(filename, 'w') as f:
        query_base = """
        INSERT INTO registry.vpa (vid,vpa, bid, vevt, eid, eby)
        VALUES
        """
        
        values_list = []

        for i in range(num_rows):
            vpa = 'vpa@aqz' + str(i + 1)
            bid = fake.random.choice(bid_list)
            values_list.append(f"({i + 1},'{vpa}', {bid}, 'VPA_ONBOARDED', 1, 1)")

        query_values = ",\n".join(values_list)
        final_query = query_base + query_values + ";"

        f.write(final_query + "\n")

store_queries_to_file(50000)
