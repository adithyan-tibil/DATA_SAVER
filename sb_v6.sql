
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

			SELECT mid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
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

			SELECT mid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
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

			SELECT mid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
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
            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Merchant does not exist or is deactivated');
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'Device does not exist or is deactivated');
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND mid IS NOT NULL AND isd = FALSE) THEN
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
    		SELECT brid INTO values_tester2 FROM registry.merchants WHERE mid = mp_id AND isd = FALSE;
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

		
		-- WHEN evt='REALLOCATE_TO_MERCHANT' THEN

  --           IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
  --               messages := array_append(messages, 'Device does not exist or is deactivated');
  --           END IF;

  --           IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mid = mp_id AND isd = FALSE) THEN
  --               messages := array_append(messages, 'Merchant does not exist or is deactivated');
  --           END IF;

		-- 	SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
  --   		SELECT brid INTO values_tester2 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE;
  --   		IF values_tester IS NOT NULL AND values_tester2 IS NOT NULL THEN
  --       		IF values_tester != values_tester2 THEN
  --           		messages := array_append(messages, 'Merchant and device belong to different branches');
  --       		END IF;
  --   		END IF;
			
		-- 	SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
		-- 	IF values_tester IS NOT NULL THEN
		-- 		IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
		-- 			messages := array_append(messages, 'device contains deactivated branch');
		-- 		END IF;	
		-- 	END IF;	
			
		-- 	SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
		-- 	IF values_tester IS NOT NULL THEN
		-- 		IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester AND isd = FALSE) THEN
		-- 			messages := array_append(messages, 'device contains deactivated bank');
		-- 		END IF;	
		-- 	END IF;
		
			
			
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------
											--DEACTIVATE--
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------


		WHEN evt='DEACTIVATE_VPA' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'VPA does not exist or already deactivated');
            END IF;
					
		WHEN evt='DEACTIVATE_DEVICE' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'DEVICE does not exist or already deactivated');
            END IF;		

		WHEN evt='DEACTIVATE_BANK' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE) THEN
                messages := array_append(messages, 'BANK does not exist or already deactivated');
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
RETURNS TABLE (
    row_id INTEGER, 
    status INTEGER, 
    msg TEXT[], 
    id_headers TEXT[], 
    id_values INT[], 
    e_at TIMESTAMP
) AS $$
DECLARE
    validator_result TEXT[];
    id_values RECORD;
    headers_array TEXT[] := ARRAY['sid', 'vid', 'did', 'bid', 'brid', 'mpid']; 

BEGIN
    validator_result := registry.sb_validator(evt, v_id, d_id, b_id, br_id, mp_id);

    IF array_length(validator_result, 1) > 0 THEN
        RETURN QUERY SELECT rowid, 0, validator_result, ARRAY[]::text[], ARRAY[]::integer[],NULL::timestamp ; 

    ELSE
        CASE
            WHEN evt = 'VPA_DEVICE_BOUND' THEN
                UPDATE registry.sb
                SET 
                    sbevt = 'VPA_DEVICE_BOUND',
                    vid = v_id,
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE did = d_id AND isd = FALSE
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;

            WHEN evt = 'ALLOCATE_TO_BANK' THEN
                UPDATE registry.sb
                SET 
                    sbevt = 'ALLOCATED_TO_BANK',
                    bid = b_id,
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE did = d_id AND isd = FALSE
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;

            WHEN evt = 'ALLOCATE_TO_BRANCH' THEN
                UPDATE registry.sb
                SET 
                    sbevt = 'ALLOCATED_TO_BRANCH',
                    brid = br_id,
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE did = d_id AND isd = FALSE
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;

            WHEN evt = 'ALLOCATE_TO_MERCHANT' THEN
                UPDATE registry.sb
                SET 
                    sbevt = 'ALLOCATED_TO_MERCHANT',
                    mid = mp_id,
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE did = d_id AND isd = FALSE
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;

			----DEACTIVATE

			WHEN evt='DEACTIVATE_DEVICE' THEN
				UPDATE registry.devices
				SET
					devt = 'DEVICE_DEACTIVATED',
					isd = true,
					eby = e_by,
                    eat = CURRENT_TIMESTAMP
				WHERE did = d_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'DEVICE_DEACTIVATED',
                    isd = true,	
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE did = d_id AND isd = FALSE				
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;


			WHEN evt='DEACTIVATE_BANK' THEN
				UPDATE registry.banks
				SET
					bevt = 'BANK_DEACTIVATED',
					isd = true,
					eby = e_by,
                    eat = CURRENT_TIMESTAMP
				WHERE bid = b_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'BANK_DEACTIVATED',
                    isd = true,	
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE bid = b_id AND isd = FALSE				
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;
				
			WHEN evt='DEACTIVATE_VPA' THEN
				UPDATE registry.vpa
				SET
					vevt = 'VPA_DEACTIVATED',
					isd = true,
					eby = e_by,
                    eat = CURRENT_TIMESTAMP
				WHERE vid = v_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'VPA_DEACTIVATED',
                    isd = true,	
                    eby = e_by,
                    eat = CURRENT_TIMESTAMP
                WHERE vid = v_id AND isd = FALSE				
                RETURNING sid, vid, did, bid, brid, mpid, eat INTO id_values;
			
            ELSE
                RAISE EXCEPTION 'Unsupported event type: %', evt;
        END CASE;

        RETURN QUERY SELECT 
            rowid, 
            1, 
            ARRAY['SUCCESS'], 
            headers_array, 
            ARRAY[id_values.sid, id_values.vid, id_values.did, id_values.bid, id_values.brid, id_values.mpid], 
            id_values.eat;
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
-- RETURNS TABLE (row_id INTEGER, status INTEGER, msg TEXT[],sid INTEGER,vid INTEGER,did INTEGER,bid INTEGER,brid INTEGER,mpid INTEGER,eat timestamp) AS $$
RETURNS TABLE (row_id INTEGER, status INTEGER, msg TEXT[],id_headers TEXT[],id_values INT[],eat timestamp) AS $$
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
	ARRAY[1],
	'DEACTIVATE_VPA',
	ARRAY[3]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[1]::INTEGER[],
	ARRAY[]::INTEGER[]
)