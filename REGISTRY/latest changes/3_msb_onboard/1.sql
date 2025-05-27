CREATE TABLE IF NOT EXISTS registry.dtypes(
dtid SERIAL PRIMARY KEY,
dtname VARCHAR(25),
description VARCHAR(500),
isd bool
);

INSERT INTO registry.dtypes(dtname,description) VALUES 
('MSB', 'Mobile Soundbox'),
('SB', 'Soundbox')

ALTER TABLE registry.devices
ADD COLUMN dtid INTEGER REFERENCES registry.dtypes(dtid);




--------------MSB ENUM--------------------

CREATE TYPE registry.msb_devices_msgs AS ENUM (
		'SUCCESS_INSERT',
		'DEVICE_REPEATED',
		'INVALID_BANK',
		'INVALID_BRANCH',
		'INVALID_MERCHANT',
		'NO_SB_DEVICE_FOUND'
);


-----------------------MSB FUNCTIONS----------------------

DROP FUNCTION IF EXISTS registry.msb_device_validator,registry.msb_device_validator_writer,registry.msb_device_iterator;

CREATE OR REPLACE FUNCTION registry.msb_device_validator(d_name VARCHAR,b_id INTEGER,br_id INTEGER,mp_id INTEGER) 
RETURNS registry.msb_devices_msgs[] AS $$
DECLARE
    messages registry.msb_devices_msgs[] := ARRAY[]::registry.msb_devices_msgs[];
BEGIN
   			IF EXISTS (SELECT 1 FROM registry.devices WHERE dname = d_name ) THEN
       		 messages := array_append(messages, 'DEVICE_REPEATED'::registry.msb_devices_msgs);
    		END IF;	

			IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE AND isa = True) THEN
                messages := array_append(messages, 'INVALID_BANK'::registry.msb_devices_msgs);
            END IF;

			IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE AND isa = True) THEN
                messages := array_append(messages, 'INVALID_BRANCH'::registry.msb_devices_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE AND isa = True) THEN
                messages := array_append(messages, 'INVALID_MERCHANT'::registry.msb_devices_msgs);
            END IF;

			IF NOT EXISTS (SELECT 1 FROM registry.sb WHERE mid = mp_id AND isd = FALSE AND isa = True) THEN
			     messages := array_append(messages, 'NO_SB_DEVICE_FOUND'::registry.msb_devices_msgs);
            END IF;

    RETURN messages;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION registry.msb_device_validator_writer(
    rowid INTEGER,
    d_name VARCHAR,
    b_name VARCHAR ,
    br_name VARCHAR,
	m_name VARCHAR,
    e_by VARCHAR,
    e_id INTEGER
)
RETURNS TABLE (row_id INTEGER, status INTEGER, msg registry.msb_devices_msgs[],d_names VARCHAR) AS $$
DECLARE
    devt registry.devts := 'DEVICE_ONBOARDED';
	device_name VARCHAR := null;
	validator_result registry.msb_devices_msgs[];
	d_id INTEGER;
	b_id INTEGER;
    br_id INTEGER;
    mp_id INTEGER;
	dt_id INTEGER;
BEGIN
    SELECT bid INTO b_id FROM registry.banks WHERE bname = b_name ;
    SELECT brid INTO br_id FROM registry.branches WHERE brname = br_name ;
    SELECT mpid INTO mp_id FROM registry.merchants WHERE mname = m_name ;
	SELECT dtid INTO dt_id FROM registry.dtypes WHERE dtname = 'MSB';

	validator_result := registry.msb_device_validator(d_name,b_id,br_id,mp_id);
	
	IF array_length(validator_result, 1) > 0 THEN
		RETURN QUERY SELECT rowid,0,validator_result,device_name;
		RETURN;
	END IF;
	
    INSERT INTO registry.devices (eid, devt, eby, dname, mfid, mdid, fid,imei,dtid)
		    VALUES (e_id, devt, e_by, d_name, null, null, null,d_name,dt_id)
			RETURNING dname,did INTO device_name,d_id;

	UPDATE registry.sb
            SET 
                sbevt = 'ALLOCATED_TO_BANK',
                bid = b_id,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE;
			
	UPDATE registry.sb
            SET 
                sbevt = 'ALLOCATED_TO_BRANCH',
                brid = br_id,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE;

			
    UPDATE registry.sb
            SET 
                sbevt = 'ALLOCATED_TO_MERCHANT',
                mid = mp_id,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE;

	RETURN QUERY SELECT rowid, 1, ARRAY['SUCCESS_INSERT']::registry.msb_devices_msgs[],device_name;

	
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION registry.msb_device_iterator(
	rowid INT[],
    dnames TEXT[],
	bnames TEXT[],
	brnames TEXT[],
	mnames TEXT[],
    event_bys TEXT[],
    eids INT[]
) 
RETURNS TABLE (row_id INTEGER, status INTEGER, msg registry.msb_devices_msgs[], did VARCHAR) AS
$$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..array_length(rowid, 1) LOOP
  
        RETURN QUERY SELECT * FROM registry.msb_device_validator_writer(
			rowid[i],
    		dnames[i],
			bnames[i] ,
   			brnames[i],
			mnames[i],
    		event_bys[i],   
            eids[i]
        ); 
    END LOOP; 
END;
$$ LANGUAGE plpgsql;

-------------------CALLABLE QUERY--------------------------
-- SELECT * FROM registry.msb_device_iterator(
--     ARRAY[1, 2],                          -- rowid
--     ARRAY['86060696208', '86060696209'],       -- dnames
--     ARRAY['bank_1', 'bank_1'],           -- bnames
--     ARRAY['branch_1', 'branch_1'],       -- brnames
--     ARRAY['merchant_1', 'merchant_2'],   -- mnames
--     ARRAY['admin', 'admin'],             -- event_bys
--     ARRAY[1001, 1002]                    -- eids
-- );


