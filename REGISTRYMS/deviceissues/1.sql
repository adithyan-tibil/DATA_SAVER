CREATE TYPE registry.di_status AS ENUM(
	'Resolved',
	'Invalid-Closed'
)




CREATE TABLE registry.device_issues (
    diid SERIAL PRIMARY KEY,
    bank VARCHAR,
    vpa VARCHAR,
    device VARCHAR,
    branch VARCHAR,
    merchant VARCHAR,
    mphno VARCHAR,
    issue_desc TEXT,
    status registry.di_status,
    eat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    eid INTEGER NOT NULL,
    eby VARCHAR NOT NULL
);


CREATE OR REPLACE FUNCTION registry.raise_device_issues(
	device_issue_id INTEGER,
	context VARCHAR,
    d_name VARCHAR,
	b_name VARCHAR,
	br_name VARCHAR,
	v_name VARCHAR,
	m_name VARCHAR,
	m_phno JSON ,
	di_status registry.di_status,
	d_issue TEXT,
	e_by VARCHAR,
	e_id INTEGER 
	
)
RETURNS TABLE (
	msg TEXT,
	diid INTEGER,
	merchantName VARCHAR,
	merchantphno JSON ,
	diStatus registry.di_status,
	issue TEXT,
	eventID INTEGER
	
	

) AS $$
DECLARE
	deviceissue_id INTEGER;
	device_name VARCHAR;
    vpa_name VARCHAR;
    merchant_name VARCHAR;
	merchant_phno JSON;
	issue_status registry.di_status;
	issue_desc TEXT;
	event_id INTEGER;
	
BEGIN

	IF context = 'CREATE' THEN
		INSERT INTO registry.device_issues AS di(device,bank,branch,vpa,merchant,mphno,status,issue_desc,eby,eid)
		VALUES (d_name,b_name,br_name,vpa_name,m_name,m_phno,di_status,device_issue,e_by,e_id)
		RETURNING di.diid INTO deviceissue_id;
		RETURN QUERY SELECT 'ISSUE_CREATED',deviceissue_id,d_name,v_name,m_name,m_phno,di_status,d_issue,e_id;

	
	ELSIF context = 'UPDATE' THEN
	  IF EXISTS(SELECT 1 FROM registry.device_issues AS di WHERE di.diid = device_issue_id ) THEN
		UPDATE registry.device_issues AS di
			SET
				status = di_status,
				eby = e_by,
				eid = e_id
			WHERE dr.drid = device_issue_id
		RETURNING device,vpa,merchant,mphno,status,issue_desc,eid INTO device_name,vpa_name,merchant_name,merchant_phno,issue_status,issue_desc,event_id ;
		RETURN QUERY SELECT 'ISSUE_UPDATED',device_issue_id,device_name,vpa_name,merchant_name,merchant_phno,issue_status,issue_desc,event_id;
	  ELSE 
	  	RETURN QUERY SELECT 'INVALID_DIID',device_issue_id,device_name,vpa_name,merchant_name,merchant_phno,issue_status,issue_desc,event_id;
	  END IF;
	END IF;
		

END;
$$ LANGUAGE plpgsql;