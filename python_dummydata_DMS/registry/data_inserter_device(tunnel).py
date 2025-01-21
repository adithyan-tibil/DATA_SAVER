import psycopg2
from faker import Faker

def store_queries_to_file(num_rows):
    filename = '/home/aditya/adithyan/TIBIL_GIT/DATA_SAVER/python_dummydata_DMS/datastore/queries.txt'


    fake = Faker()
    mfid_list = [1]
    fid_list = [1]
    mdid_list = [1]

    with open(filename, 'w') as f:
        query_base = """
        INSERT INTO registry.devices (did,dname, mfid, fid, mdid, devt, eid, eby)
        VALUES
        """
        
        values_list = []

        for i in range(num_rows):
            dname = 'device_' + str(i+200000)
            mfid = fake.random.choice(mfid_list)
            fid = fake.random.choice(fid_list)
            mdid = fake.random.choice(mdid_list)
            values_list.append(f"({i+200001},'{dname}', {mfid}, {fid}, {mdid}, 'DEVICE_ONBOARDED', 1, 1)")

        query_values = ",\n".join(values_list)
        final_query = query_base + query_values + ";"

        f.write(final_query + "\n")

store_queries_to_file(100000)
