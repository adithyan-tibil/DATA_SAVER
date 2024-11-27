import psycopg2
from faker import Faker

def insert_devices(num_rows):
    # Database connection setup
    conn = psycopg2.connect(
        dbname="registryMS",
        user="postgres",
        password="tibil123",
        host="localhost",
        port="5432"
    )
    cursor = conn.cursor()

    # Data generation setup
    fake = Faker()
    vpas = set()
    bid_list = [5]


    # Insert rows
    for i in range(num_rows):
        # Generate a unique device name
        vpa = fake.name()+str(i)
        vpas.add(vpa)
        
        # Select random values for mfid, fid, and mdid
        bid = fake.random.choice(bid_list)
      

        # Insert query
        query = """
        INSERT INTO registry.vpa (vpa, bid, vevt, eid, eby)
        VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(query, (vpa,bid ,'VPA_ONBOARDED', 1, 1))

    # Commit and close
    conn.commit()
    cursor.close()
    conn.close()

insert_devices(20)  # Inserts 100 rows into the table
