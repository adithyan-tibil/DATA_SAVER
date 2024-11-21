-- CREATE OR REPLACE FUNCTION registry.sb_validator(s_id INTEGER,v_id INTEGER,d_id INTEGER,b_id INTEGER,br_id INTEGER,m_id INTEGER) 
-- RETURNS INTEGER AS $$
-- BEGIN
-- 	-----DEVICE_VPA_ONBOARD
-- 	IF v_id is NOT NULL and d_id IS NOT NULL THEN
-- 		IF EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id and isd = FALSE) THEN
-- 			IF EXISTS (SELECT 1 FROM registry.device WHERE did = d_id AND isd = FALSE) THEN
-- 				IF NOT EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id) AND NOT EXISTS (SELECT 1 FROM registry.sb WHERE vid = v_id) THEN
-- 					RETURN 1;
-- 				ELSE
-- 					RETURN 10;
-- 				END IF;
-- 			ELSE 
-- 				RETURN 11;
-- 			END IF;
-- 		ELSE 
-- 			RETURN 12;
-- 		END IF;

-- 	------ALLOCATED_TO_BANK
-- 	ELSIF b_id is NOT NULL THEN
-- 		IF EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE) THEN
-- 		 	RETURN 2;
-- 		ELSE
-- 			RETURN 20;
-- 		END IF;

-- 	-----ALLOCATED_TO_BRANCH
-- 	ELSIF br_id IS NOT NULL THEN
-- 		IF EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE) THEN
-- 			RETURN 3;
-- 		ELSE 
-- 			RETURN 30;
-- 		END IF;

-- 	------ALLOCATED_TO_MERHCANT
-- 	ELSIF m_id IS NOT NULL THEN
-- 		IF EXISTS (SELECT 1 FROM registry.mf WHERE mid = m_id AND isd = FALSE) THEN
-- 			RETURN 4;
-- 		ELSE 
-- 			RETURN 40;
-- 		END IF;	
-- 	ELSE
-- 		RETURN 0;
-- 	END IF;
			    
-- END;
-- $$ LANGUAGE plpgsql;




-- CREATE OR REPLACE FUNCTION registry.sb_validator_writer(
--     rowid INTEGER,
-- 	s_id INTEGER,
-- 	v_id INTEGER,	
--     d_id INTEGER,
--     b_id INTEGER,
--     br_id INTEGER,
-- 	m_id INTEGER,
--     e_by INTEGER,
--     eid INTEGER
-- )
-- RETURNS TABLE (row_id INTEGER, status INTEGER, msg TEXT,sb_id INTEGER) AS $$
-- DECLARE
--     sb_id INTEGER := NULL;
-- 	validator_result INTEGER;
-- BEGIN
-- 	validator_result :=  registry.sb_validator(s_id,v_id,d_id,b_id,br_id,m_id);
	   
-- 	IF validator_result = 1 THEN
--     	INSERT INTO registry.sb (vid, did,sbevt,eby,eid)
--     	VALUES (v_id, d_id,'VPA_DEVICE_BOUND',e_by,eid)
--    		RETURNING sid INTO sb_id ;
--    		RETURN QUERY SELECT rowid, 1, 'VPA_DEVICE_BOUNDED',sb_id;
				
-- 	ELSIF validator_result = 2 THEN
--     	UPDATE registry.sb
--        	SET 
--            	sbevt = 'ALLOCATED_TO_BANK',
--             bid = b_id,
-- 			eby = e_by
--        	WHERE sid = s_id;
--        	RETURN QUERY SELECT rowid, 1, 'ALLOCATED_TO_BANK', s_id;

-- 	ELSIF validator_result = 3 THEN
--     	UPDATE registry.sb
--        	SET 
--            	sbevt = 'ALLOCATED_TO_BRANCH',
--             brid = br_id,
-- 			eby = e_by
--        	WHERE sid = s_id;
--        	RETURN QUERY SELECT rowid, 1, 'ALLOCATED_TO_BRANCH', s_id;

-- 	ELSIF validator_result = 4 THEN
--     	UPDATE registry.sb
--        	SET 
--            	sbevt = 'ALLOCATED_TO_MERCHANT',
--             mid = m_id,
-- 			eby = e_by
--        	WHERE sid = s_id;
--        	RETURN QUERY SELECT rowid, 1, 'ALLOCATED_TO_MERCHANT', s_id;

-- 	ELSE 
-- 		RETURN QUERY SELECT rowid,0,'EVENT_FAILED',sb_id;
-- 	END IF;


-- END;
-- $$ LANGUAGE plpgsql;


-- CREATE OR REPLACE FUNCTION registry.sb_iterator(
-- 	rowid INT[],
-- 	s_id INT[],
-- 	v_id INT[],	
--     d_id INT[],
--     b_id INT[],
--     br_id INT[],
-- 	m_id INT[],
--     e_by INT[],
--     eid INT[]
-- ) 
-- RETURNS TABLE (row_id INTEGER, status INTEGER, msg TEXT,sid INTEGER) AS $$
-- DECLARE
--     i INT;
-- BEGIN
--     FOR i IN 1..array_length(rowid, 1) LOOP
  
--         RETURN QUERY SELECT * FROM registry.sb_validator_writer(
-- 			rowid[i],
-- 			COALESCE(s_id[i], NULL) ,
--             COALESCE(v_id[i],NULL),
--             COALESCE(d_id[i],NULL), 
--             COALESCE(b_id[i],NULL),
-- 			COALESCE(br_id[i],NULL),
-- 			COALESCE(m_id[i],NULL),
--             COALESCE(e_by[i],NULL), 
--             COALESCE(eid[i],NULL)
--         ); 
--     END LOOP; 
-- END;
-- $$ LANGUAGE plpgsql;


-- EXPLAIN ANALYZE
-- SELECT row_id,status,msg,sid FROM registry.sb_iterator(
-- 	ARRAY[1,2],
-- 	ARRAY[1,3]::integer[],
--     ARRAY[1,2]::integer[], 
--     ARRAY[]::integer[], 
--     ARRAY[]::integer[], 
--     ARRAY[]::integer[], 
--     ARRAY[]::integer[],
--     ARRAY[]::integer[], 
--     ARRAY[]::integer[]

-- );


--------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------SB----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ALTER TYPE registry.sbevts ADD VALUE 'DEVICE_ONBOARDED';


CREATE OR REPLACE FUNCTION registry.devices_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO registry.devices_v (did, dname, mfid, fid, mdid, devt, eid, isd, eat, eby, op)
    VALUES (NEW.did, NEW.dname, NEW.mfid, NEW.fid, NEW.mdid, NEW.devt, NEW.eid, NEW.isd, NEW.eat, NEW.eby, 'CREATED');
	INSERT INTO registry.sb(did,sbevt,eid,isd, eat, eby)
	VALUES (NEW.did,'DEVICE_ONBOARDED',NEW.eid, NEW.isd, NEW.eat, NEW.eby);
  
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.isd = true AND OLD.isd = false THEN
      INSERT INTO registry.devices_v (did, dname, mfid, fid, mdid, devt, eid, isd, eat, eby, op)
      VALUES (NEW.did, NEW.dname, NEW.mfid, NEW.fid, NEW.mdid, NEW.devt, NEW.eid, NEW.isd, NEW.eat, NEW.eby, 'DELETED');
    ELSE
      INSERT INTO registry.devices_v (did, dname, mfid, fid, mdid, devt, eid, isd, eat, eby, op)
      VALUES (NEW.did, NEW.dname, NEW.mfid, NEW.fid, NEW.mdid, NEW.devt, NEW.eid, NEW.isd, NEW.eat, NEW.eby, 'UPDATED');
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION registry.sb_validator(
	evt VARCHAR,
    v_id INTEGER,
    d_id INTEGER,
    b_id INTEGER,
    br_id INTEGER,
    mp_id INTEGER
)
RETURNS TEXT[] AS $$
DECLARE
    messages TEXT[] := ARRAY[]::TEXT[]; -- Initialize an empty text array
    values_tester INTEGER;
	values_tester2 INTEGER;
BEGIN
    CASE 
	-------------------------------BOUND_DEVICE---------------------------------------------------------------
        WHEN evt='BOUND_DEVICE' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'VPA does not exist or is deactivated');
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Device does not exist or is deactivated');
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND vid IS NOT NULL AND isd = FALSE) THEN
                messages := array_append(messages, 'Device already bounded');
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'VPA already bounded');
            END IF;

			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated bank');
				END IF;	
			END IF;

			
			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated branch');
				END IF;	
			END IF;			

			SELECT mpid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated merchant');
				END IF;	
			END IF;	

			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				SELECT bid INTO values_tester2 FROM registry.vpa WHERE vid = v_id AND isd = FALSE;
				IF values_tester != values_tester2 THEN
					messages := array_append(messages, 'allocated bank and vpa of different bank');
				END IF;
			END IF;

		-------------------------------------ALLOCATE_TO_BANK-------------------------------------------------------	

        WHEN evt='ALLOCATE_TO_BANK' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Bank does not exist or is deactivated');
            END IF;

			IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Device does not exist or is deactivated');
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND bid IS NOT NULL AND isd = FALSE) THEN
                messages := array_append(messages, 'Device already allocated to a bank');
            END IF;

			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated branch');
				END IF;	
			END IF;			

			SELECT mpid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated merchant');
				END IF;	
			END IF;	

			SELECT vid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated vpa');
				END IF;	
			END IF;				

			SELECT bid INTO values_tester FROM registry.vpa WHERE vid = (
			SELECT vid FROM registry.sb WHERE did = d_id AND isd = FALSE) AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF values_tester != b_id THEN
					messages := array_append(messages, 'VPA and device of different bank');
				END IF;
			END IF;

		----------------------------------ALLOCATE_TO_BRANCH----------------------------------------------------------
		
        WHEN evt='ALLOCATE_TO_BRANCH' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Branch does not exist or is deactivated');
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Device does not exist or is deactivated');
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND brid IS NOT NULL) THEN
                messages := array_append(messages, 'Device already allocated to a branch');
            END IF;

			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated bank');
				END IF;	
			END IF;

			SELECT mpid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated merchant');
				END IF;	
			END IF;	

			SELECT vid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated vpa');
				END IF;	
			END IF;	

   			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
    		SELECT bid INTO values_tester2 FROM registry.branches WHERE brid = br_id AND isd = FALSE;
    		IF values_tester IS NOT NULL THEN
        		IF values_tester != values_tester2 THEN
            		messages := array_append(messages, 'Branch and device belong to different banks');
        		END IF;
    		END IF;

		------------------------------------------ALLOCATE_TO_MERCHANT--------------------------------------------------

        WHEN evt='ALLOCATE_TO_MERCHANT' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mid = mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Merchant does not exist or is deactivated');
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Device does not exist or is deactivated');
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND mpid IS NOT NULL AND isd = FALSE) THEN
                messages := array_append(messages, 'Device already allocated to a merchant');
            END IF;

			-- SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id;
   --  		SELECT bid INTO values_tester2 FROM registry.merchants WHERE mid = m_id;
   --  		IF values_tester IS NOT NULL THEN
   --      		IF values_tester != values_tester2 THEN
   --          		messages := array_append(messages, 'Merchant and device belong to different banks');
   --      		END IF;
   --  		END IF;

			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated branch');
				END IF;	
			END IF;	
			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated bank');
				END IF;	
			END IF;
			SELECT vid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated vpa');
				END IF;	
			END IF;

   			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
    		SELECT brid INTO values_tester2 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE;
    		IF values_tester IS NOT NULL AND values_tester2 IS NOT NULL THEN
        		IF values_tester != values_tester2 THEN
            		messages := array_append(messages, 'Merchant and device belong to different branches');
        		END IF;
    		END IF;

			
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------
											--REALLOCATE--
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------

		-------------------------------------------------------------------------------------------
		
		WHEN evt='REALLOCATE_TO_MERCHANT' THEN

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Device does not exist or is deactivated');
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mid = mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Merchant does not exist or is deactivated');
            END IF;

			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
    		SELECT brid INTO values_tester2 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE;
    		IF values_tester IS NOT NULL AND values_tester2 IS NOT NULL THEN
        		IF values_tester != values_tester2 THEN
            		messages := array_append(messages, 'Merchant and device belong to different branches');
        		END IF;
    		END IF;
			
			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated branch');
				END IF;	
			END IF;	
			
			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester AND isd = FALSE) THEN
					messages := array_append(messages, 'device contains deactivated bank');
				END IF;	
			END IF;
		
			


			
        ELSE
            messages := array_append(messages, 'No valid event type identified');
    END CASE;

    RETURN messages;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION registry.sb_validator_writer(
    rowid INTEGER,
	evt VARCHAR,
	v_id INTEGER,	
    d_id INTEGER,
    b_id INTEGER,
    br_id INTEGER,
	mp_id INTEGER,
    e_by INTEGER,
    eid INTEGER
)
RETURNS TABLE (row_id INTEGER, status INTEGER, msg TEXT[],sb_id INTEGER) AS $$
DECLARE
	validator_result TEXT [];
	sb_id INTEGER;
BEGIN
	validator_result :=  registry.sb_validator(evt,v_id,d_id,b_id,br_id,mp_id);

	IF array_length(validator_result, 1) >0 THEN
		RETURN QUERY SELECT rowid,0,validator_result,sb_id; 

	ELSE
		CASE
			WHEN evt='VPA_DEVICE_BOUND' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'VPA_DEVICE_BOUND',
            		vid = v_id,
					eby = e_by
       			WHERE did = d_id AND isd = FALSE
				RETURNING sid INTO sb_id;
       			RETURN QUERY SELECT rowid, 1, ARRAY['VPA_DEVICE_BOUNDED'], sb_id;

			WHEN evt='ALLOCATE_TO_BANK' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'ALLOCATED_TO_BANK',
            		bid = b_id,
					eby = e_by
       			WHERE did = d_id AND isd = FALSE
				RETURNING sid INTO sb_id;
       			RETURN QUERY SELECT rowid, 1, ARRAY['ALLOCATED_TO_BANK'], sb_id;

			WHEN evt='ALLOCATE_TO_BRANCH' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'ALLOCATED_TO_BRANCH',
            		brid = br_id,
					eby = e_by
       			WHERE did = d_id AND isd = FALSE
				RETURNING sid INTO sb_id;
       			RETURN QUERY SELECT rowid, 1, ARRAY['ALLOCATED_TO_BRANCH'], sb_id;

			WHEN evt='ALLOCATE_TO_MERCHANT' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'ALLOCATED_TO_MERCHANT',
            		mpid = mp_id,
					eby = e_by
       			WHERE did = d_id AND isd = FALSE
				RETURNING sid INTO sb_id;
       			RETURN QUERY SELECT rowid, 1, ARRAY['ALLOCATED_TO_MERCHANT'], sb_id;

			WHEN evt='REALLOCATE_TO_MERCHANT' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'REALLOCATED_TO_MERCHANT',
					isd = true,
					eby = e_by
       			WHERE did = d_id AND isd = FALSE;
				INSERT INTO registry.sb(did,bid,brid,mpid,eby,sbevt) 
				VALUES (d_id,b_id,br_id,mp_id,e_by,'REALLOCATED_TO_MERCHANT')
				RETURNING sid INTO sb_id;
       			RETURN QUERY SELECT rowid, 1, ARRAY['ALLOCATED_TO_MERCHANT'], sb_id;
				
		END CASE;
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION registry.sb_iterator(
	rowid INT[],
	evt VARCHAR,
	v_id INT[],	
    d_id INT[],
    b_id INT[],
    br_id INT[],
	mp_id INT[],
    e_by INT[],
    eid INT[]
) 
RETURNS TABLE (row_id INTEGER, status INTEGER, msg TEXT[],sid INTEGER) AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..array_length(rowid, 1) LOOP
  
        RETURN QUERY SELECT * FROM registry.sb_validator_writer(
			rowid[i],
			evt,
            COALESCE(v_id[i],NULL),
            COALESCE(d_id[i],NULL), 
            COALESCE(b_id[i],NULL),
			COALESCE(br_id[i],NULL),
			COALESCE(mp_id[i],NULL),
            e_by[i], 
            COALESCE(eid[i],NULL)
        ); 
    END LOOP; 
END;
$$ LANGUAGE plpgsql;


SELECT * FROM registry.sb_iterator(
	ARRAY[1,2],
	'ALLOCATE_TO_BRANCH',
	ARRAY[]::INTEGER[],
	ARRAY[6]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[3]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[1]::INTEGER[],
	ARRAY[]::INTEGER[]
)




-- INSERT INTO table_name (column1, column2, ...)
-- VALUES (value1, value2, ...)
-- ON CONFLICT (conflict_target) 
-- DO UPDATE SET column1 = value, column2 = value
-- -- or DO NOTHING;


-- CREATE OR REPLACE FUNCTION registry.sb_validator(
-- 	sb_evt VARCHAR,
--     s_id INTEGER,
--     v_id INTEGER,
--     d_id INTEGER,
--     b_id INTEGER,
--     br_id INTEGER,
--     m_id INTEGER
-- )
-- RETURNS TABLE ( msg TEXT) AS $$
-- DECLARE values_tester INTEGER;
-- BEGIN
--     CASE 
--         WHEN 'VPA_DEVICE_BOUND' THEN
--             IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id AND isd = FALSE) THEN
--                 RETURN QUERY SELECT 'VPA does not exist or is disabled';
--             END IF;

--             IF NOT EXISTS (SELECT 1 FROM registry.device WHERE did = d_id AND isd = FALSE) THEN
--                 RETURN QUERY SELECT 'Device does not exist or is disabled';
--             END IF;

--             IF (SELECT 1 FROM registry.sb WHERE did = d_id AND vid IS NOT NULL) THEN
--                 RETURN QUERY SELECT 'Device already bounded';
--             END IF;

-- 			IF EXISTS (SELECT 1 FROM registry.sb WHERE vid = v_id) THEN
--                RETURN QUERY SELECT 'VPA already bounded';
--             END IF;

--             RETURN QUERY SELECT 'Validation Success';

--         WHEN 'ALLOCATE_TO_BANK' THEN
--             IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE) THEN
--                 RETURN QUERY SELECT 'Bank does not exist or is disabled';
--             END IF;
			
-- 			IF (SELECT 1 FROM registry.sb WHERE did = d_id AND bid IS NOT NULL) THEN
--                 RETURN QUERY SELECT 'Device already allocated';
--             END IF;
--             RETURN QUERY SELECT 'Validation Success';

--         WHEN 'ALLOCATE_TO_BRANCH' THEN
--             IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE) THEN
--                 RETURN QUERY SELECT 'Branch does not exist or is disabled';
--             END IF;

-- 			SELECT bid FROM registry.sb WHERE mid=m_id INTO values_tester;
-- 			IF values_tester = 
			
-- 			IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND brid IS NOT NULL) THEN
--                 RETURN QUERY SELECT 'Device already allocated';
--             END IF;
--             RETURN QUERY SELECT 'Validation Success';

--         WHEN 'ALLOCATE_TO_MERCHANT' THEN
--             IF NOT EXISTS (SELECT 1 FROM registry.mf WHERE mid = m_id AND isd = FALSE) THEN
--                 RETURN QUERY SELECT 'Merchant does not exist or is disabled';
--             END IF;
-- 			IF (SELECT 1 FROM registry.sb WHERE did = d_id AND mid IS NOT NULL) THEN
--                 RETURN QUERY SELECT 'Device already allocated';
--             END IF;

--             RETURN QUERY SELECT 'Validation Success';

--         ELSE
--             RETURN QUERY SELECT 'No valid event type identified';
--     END CASE;
-- END;
-- $$ LANGUAGE plpgsql;


-------------------
