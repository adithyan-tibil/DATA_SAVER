import psycopg2
from faker import Faker

import psycopg2
from sshtunnel import SSHTunnelForwarder



ssh_host = '65.1.148.158'  # Replace with your SSH server address (e.g., bastion server)
ssh_port = 22  # Default SSH port
ssh_user = 'ubuntu'  # SSH username
ssh_private_key = '/home/aditya/Downloads/dms-key.pem'  # Path to your private key file

# PostgreSQL connection details
db_host = 'dms-private-db-dev.c1asoyckgmlk.ap-south-1.rds.amazonaws.com'
db_port = 5435
db_name = 'sandboxDMSdb'
db_user = 'postgres'
db_password = 'dmsadminpassword'

# Establish SSH tunnel

    

def insert_devices(num_rows):
 with SSHTunnelForwarder(
    (ssh_host, ssh_port),
    ssh_username=ssh_user,
    ssh_pkey=ssh_private_key,
    remote_bind_address=(db_host, db_port),
    local_bind_address=('127.0.0.1', 6543)  # Local port for the tunnel
 ) as tunnel:
    # Connect to PostgreSQL through the tunnel
    conn = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host='127.0.0.1',  # The local address the tunnel is forwarding to
        port=tunnel.local_bind_port  # The local port to connect to
    )
    cursor = conn.cursor()

    # Data generation setup
    fake = Faker()
    bnames = set()

    # Insert rows
    for i in range(num_rows):
        # Generate a unique device name
        bname = 'bank_'+''+str(i+1)
        bnames.add(bname)
        baddr=fake.address()
        binfo='{"name": "john", "phno": "+123456789012", "email": "abc@gmail.com"}'

        # Insert query
        query = """
        INSERT INTO registry.banks (bid,bname, baddr, binfo,bevt, eid, eby)
        VALUES (%s,%s, %s, %s, %s, %s, %s);
        """
        cursor.execute(query, (i+1,bname, baddr, binfo, 'BANK_ONBOARDED', 1, 1))
        

    # Commit and close
    conn.commit()
    cursor.close()
    conn.close()

insert_devices(2)  # Inserts 100 rows into the table
