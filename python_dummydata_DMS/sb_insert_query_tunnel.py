import psycopg2
from faker import Faker

def store_queries_to_file(num_rows):
    filename = '/home/aditya/adithyan/TIBIL_GIT/DATA_SAVER/python_dummydata_DMS/datastore/queries.txt'


    fake = Faker()


    with open(filename, 'w') as f:
        query_base = """
        INSERT INTO registry.sb (sid,did,vid,bid,brid,sbevt, eby, eid)
        VALUES
        """
        
        values_list = []

        for i in range(num_rows):
            did = i+200001
            vid = i+200001
            bid = 1
            brid = 1
            values_list.append(f"({i+200001},'{did}', {vid}, {bid}, {brid}, 'ALLOCATED_TO_BRANCH', 'abc@123', 1)")

        query_values = ",\n".join(values_list)
        final_query = query_base + query_values + ";"

        f.write(final_query + "\n")

store_queries_to_file(100000)
