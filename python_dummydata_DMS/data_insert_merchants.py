import psycopg2
from faker import Faker

def insert_devices(num_rows):
    # Database connection setup
    conn = psycopg2.connect(
        dbname="dms-db",
        user="postgres",
        password="tibil2024",
        host="dms-db.c1asoyckgmlk.ap-south-1.rds.amazonaws.com",
        port="5432"
    )
    cursor = conn.cursor()

    # Data generation setup
    fake = Faker()
    mnames = set()
    bid_list = [44925]

    # Insert rows
    for i in range(num_rows):
        # Generate a unique device name
        mname = 'merchant_'+''+str(i+10)
        mnames.add(mname)
        minfo='{"name": "john", "phno": "+123456789012", "email": "abc@gmail.com"}'
        msid = fake.random.randint(100, 9999)
        brid = 51
        bid = fake.random.choice(bid_list)

        
        # Insert query
        query = """
        INSERT INTO registry.merchants (mname, minfo, msid,bid,brid,mevt, eid, eby)
        VALUES (%s, %s, %s, %s, %s, %s,%s,%s);
        """
        cursor.execute(query, (mname, minfo, msid,bid,brid, 'MERCHANT_ONBOARDED', 1, 1))

    # Commit and close
    conn.commit()
    cursor.close()
    conn.close()

insert_devices(10)  # Inserts 100 rows into the table
