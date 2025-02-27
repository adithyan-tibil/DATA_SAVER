CREATE TYPE registry.dr_status AS ENUM(
	'Open',
	'Allocated',
	'Dispatched',
	'Delivered'
)

-- CREATE TYPE registry.drevts AS ENUM(
-- 	'DEVICE_REQUEST_CREATED',
-- 	'DEVICE_REQUEST_ALLOCATED',
-- 	'DEVICE_REQUEST_DISPATCHED',
-- 	'DEVICE_REQUEST_DELIVERED'
-- )


CREATE TABLE registry.device_requests (
	drid SERIAL PRIMARY KEY,
	bank VARCHAR ,
	branch VARCHAR ,
	merchant VARCHAR ,
	minfo JSON ,
	-- drevt registry.drevts,
	status registry.dr_status DEFAULT 'OPEN',
	comment TEXT,
	eat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	eby VARCHAR NOT NULL,
	eid INTEGER NOT NULL
)



CREATE OR REPLACE FUNCTION registry.request_for_device(
	dr_id INTEGER,
	context VARCHAR,
	b_name VARCHAR,
	br_name VARCHAR,
	m_name VARCHAR,
	m_info JSON ,
	dr_status registry.dr_status,
	-- r_comment TEXT,
	e_by VARCHAR,
	e_id INTEGER 
	
)
RETURNS TABLE (
	msg TEXT,
	bankName VARCHAR,
	branchName VARCHAR,
	merchantName VARCHAR,
	merchantInfo JSON ,
	drStatus registry.dr_status,
	eventId INTEGER,
	-- rcomment TEXT,
	devicerequestid INTEGER

) AS $$
DECLARE
	devicerequest_id INTEGER;
	bank_name VARCHAR;
	branch_name VARCHAR;
	merchant_name VARCHAR;
	merchant_info JSON;
	request_status registry.dr_status;
	event_id INTEGER;
	
BEGIN

	IF context = 'CREATE' THEN
		INSERT INTO registry.device_requests(bank,branch,merchant,minfo,status,eby,eid)
		VALUES (b_name,br_name,m_name,m_info,dr_status,e_by,e_id)
		RETURNING drid INTO devicerequest_id;
		RETURN QUERY SELECT 'REQUEST_CREATED',b_name,br_name,m_name,m_info,dr_status,e_id,devicerequest_id;
		-- RETURNING bank,branch,merchant,minfo,status,eid INTO bank_name ,branch_name,merchant_name,merchant_info,request_status,event_id ;
		-- RETURN QUERY SELECT 'REQUEST_CREATED',bank_name,branch_name,merchant_name,merchant_info,request_status,event_id,dr_id;
	
	
	ELSIF context = 'UPDATE' THEN
		UPDATE registry.device_requests
			SET
				status = dr_status,
				eby = e_by
			WHERE drid = dr_id
		RETURNING bank,branch,merchant,minfo,status,eid INTO bank_name ,branch_name,merchant_name,merchant_info,request_status,event_id ;
		RETURN QUERY SELECT 'REQUEST_UPDATED',bank_name,branch_name,merchant_name,merchant_info,request_status,event_id,dr_id;
	
	END IF;
		

END;
$$ LANGUAGE plpgsql;


SELECT * FROM registry.request_for_device(
	3,
	'CREATE',
	'bank_1',
	'branch_1',
	'merchant_1',
	'{"accNo":123,"name":"abc","phone":1234}' ,
	'OPEN',
	'abc2',
	5
)