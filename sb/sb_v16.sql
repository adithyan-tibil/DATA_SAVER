DROP FUNCTION IF EXISTS 
    registry.sb_validator,
    registry.sb_validator_writer,
    registry.sb_iterator


CREATE OR REPLACE FUNCTION registry.sb_validator(
	evt VARCHAR,
    v_id INTEGER,
    d_id INTEGER,
    b_id INTEGER,
    br_id INTEGER,
    mp_id INTEGER
)
RETURNS registry.sb_msgs[] AS $$
DECLARE
    messages registry.sb_msgs[] := ARRAY[]::registry.sb_msgs[]; 
    values_tester INTEGER;
	values_tester2 INTEGER;
BEGIN
    CASE 
	-------------------------------BIND_DEVICE---------------------------------------------------------------
        WHEN evt='BIND_DEVICE' THEN

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND vid IS NOT NULL AND isd = FALSE) THEN
                messages := array_append(messages, 'DEVICE_ALREADY_BINDED'::registry.sb_msgs);
            END IF;

			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_BANK'::registry.sb_msgs);
				END IF;	
			END IF;
			
			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_BRANCH'::registry.sb_msgs);
				END IF;	
			END IF;			

			SELECT mid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_MERCHANT'::registry.sb_msgs);
				END IF;	
			END IF;	

        -------------------------------------UNBIND_DEVICE-------------------------------------------------------

        WHEN evt='UNBIND_DEVICE' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_VPA'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'DEVICE_VPA_NOT_BINDED'::registry.sb_msgs);
            END IF;

		-------------------------------------ALLOCATE_TO_BANK-------------------------------------------------------	

        WHEN evt='ALLOCATE_TO_BANK' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_BANK'::registry.sb_msgs);
            END IF;

			IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND bid IS NOT NULL AND isd = FALSE) THEN
                messages := array_append(messages, 'BANK_ALREADY_ALLOCATED'::registry.sb_msgs);
            END IF;

			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_BRANCH'::registry.sb_msgs);
				END IF;	
			END IF;			

			SELECT mid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_MERCHANT'::registry.sb_msgs);
				END IF;	
			END IF;	

			SELECT vid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_VPA'::registry.sb_msgs);
				END IF;	
			END IF;				

			SELECT bid INTO values_tester FROM registry.vpa WHERE vid = (
			SELECT vid FROM registry.sb WHERE did = d_id AND isd = FALSE) AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF values_tester != b_id THEN
					messages := array_append(messages, 'VPA_BANK_UNMATCHED_BID'::registry.sb_msgs);
				END IF;
			END IF;

		----------------------------------ALLOCATE_TO_BRANCH----------------------------------------------------------
		
        WHEN evt='ALLOCATE_TO_BRANCH' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_BRANCH'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND brid IS NOT NULL) THEN
                messages := array_append(messages,'BRANCH_ALREADY_ALLOCATED'::registry.sb_msgs);
            END IF;

			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_BANK'::registry.sb_msgs);
				END IF;	
			END IF;

			SELECT mid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_MERCHANT'::registry.sb_msgs);
				END IF;	
			END IF;	

			SELECT vid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_VPA'::registry.sb_msgs);
				END IF;	
			END IF;	

   			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
    		IF values_tester IS NOT NULL THEN
				SELECT bid INTO values_tester2 FROM registry.branches WHERE brid = br_id AND isd = FALSE;
        		IF values_tester != values_tester2 THEN
            		messages := array_append(messages, 'BANK_BRANCH_UNMATCHED'::registry.sb_msgs);
        		END IF;
    		END IF;

		------------------------------------------ALLOCATE_TO_MERCHANT--------------------------------------------------

        WHEN evt='ALLOCATE_TO_MERCHANT' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_MERCHANT'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND mid IS NOT NULL AND isd = FALSE) THEN
                messages := array_append(messages, 'MERCHANT_ALREADY_ALLOCATED'::registry.sb_msgs);
            END IF;

			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_BRANCH'::registry.sb_msgs);
				END IF;	
			END IF;	
			SELECT bid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_BANK'::registry.sb_msgs);
				END IF;	
			END IF;
			SELECT vid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
			IF values_tester IS NOT NULL THEN
				IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid=values_tester and isd = FALSE) THEN
					messages := array_append(messages, 'DEVICE_DEACTIVATED_VPA'::registry.sb_msgs);
				END IF;	
			END IF;

   			SELECT brid INTO values_tester FROM registry.sb WHERE did = d_id AND isd = FALSE;
    		SELECT brid INTO values_tester2 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE;
    		IF values_tester IS NOT NULL AND values_tester2 IS NOT NULL THEN
        		IF values_tester != values_tester2 THEN
            		messages := array_append(messages, 'BANK_MERCHANT_UNMATCHED_BID'::registry.sb_msgs);
        		END IF;
    		END IF;

		
			
			
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------
											--DEACTIVATE--
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------


		WHEN evt='DEACTIVATE_VPA' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_VPA'::registry.sb_msgs);
            END IF;
					
		WHEN evt='DEACTIVATE_DEVICE' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;		

		WHEN evt='DEACTIVATE_BRANCH' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_BRANCH'::registry.sb_msgs);
            END IF;		
			
		WHEN evt='DEACTIVATE_MERCHANT' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_MERCHANT'::registry.sb_msgs);
            END IF;				
        
        WHEN evt='DEACTIVATE_BANK' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.banks WHERE bid = b_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_BANK'::registry.sb_msgs);
            END IF;

			
		WHEN evt='DELETE_VPA' THEN
			IF NOT EXISTS (SELECT 1 FROM registry.vpa WHERE vid = v_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_VPA'::registry.sb_msgs);
            END IF;

		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------
											--REALLOCATE--
		-------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------
		
        WHEN evt='REALLOCATE_TO_MERCHANT' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE mpid = mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_MERCHANT'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

            IF EXISTS (SELECT 1 FROM registry.sb WHERE mid=mp_id AND isd = FALSE) THEN
                messages := array_append(messages, 'MERCHANT_ALREADY_ALLOCATED'::registry.sb_msgs);
            END IF;

        WHEN evt='REALLOCATE_TO_BRANCH' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.branches WHERE brid = br_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_BRANCH'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

        WHEN evt='REALLOCATE_TO_BANK' THEN
            IF NOT EXISTS (SELECT 1 FROM registry.merchants WHERE bid = b_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_BANK'::registry.sb_msgs);
            END IF;

            IF NOT EXISTS (SELECT 1 FROM registry.devices WHERE did = d_id AND isd = FALSE) THEN
                messages := array_append(messages, 'INVALID_DEVICE'::registry.sb_msgs);
            END IF;

        ELSE
            messages := array_append(messages, 'INVALID_EVENT'::registry.sb_msgs);
    END CASE;

    RETURN messages;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION registry.sb_validator_writer(
    rowid INTEGER,
    evt VARCHAR,
    vpa_ VARCHAR,    
    d_id INTEGER,
    b_id INTEGER,
    br_id INTEGER,
    mp_id INTEGER,
    e_by VARCHAR,
    e_id INTEGER
)
RETURNS TABLE (
    row_id INTEGER, 
    status INTEGER, 
    msgs registry.sb_msgs[], 
    id_headers TEXT[], 
    id_values INT[], 
    e_at TIMESTAMP
) AS $$
DECLARE
    v_id INTEGER;
    validator_result registry.sb_msgs[];
    id_values RECORD;
    headers_array TEXT[] := ARRAY['sid', 'vid', 'did', 'bid', 'brid', 'mid']; 

BEGIN
	SELECT vid INTO v_id FROM registry.vpa WHERE vpa = vpa_ ;
	
    validator_result := registry.sb_validator(evt, v_id, d_id, b_id, br_id, mp_id);

    IF array_length(validator_result, 1) > 0 THEN
        RETURN QUERY SELECT rowid, 0, validator_result, ARRAY[]::text[], ARRAY[]::integer[], NULL::timestamp; 
   		RETURN; 
	END IF;

    CASE
        WHEN evt = 'BIND_DEVICE' THEN
            UPDATE registry.sb
            SET 
                sbevt = 'VPA_DEVICE_BOUND',
                vid = (SELECT vpa.vid FROM registry.vpa WHERE bid = b_id AND NOT EXISTS (SELECT 1 FROM registry.sb WHERE sb.vid = vpa.vid AND isd = false and isa = true)LIMIT 1),
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE
            RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;

        WHEN evt = 'UNBIND_DEVICE' THEN
            UPDATE registry.sb
            SET 
                sbevt = 'VPA_DEVICE_UNBOUND',
                vid = null,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE
            RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;

        WHEN evt = 'ALLOCATE_TO_BANK' THEN
            UPDATE registry.sb
            SET 
                sbevt = 'ALLOCATED_TO_BANK',
                bid = b_id,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE
            RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;

        WHEN evt = 'ALLOCATE_TO_BRANCH' THEN
            UPDATE registry.sb
            SET 
                sbevt = 'ALLOCATED_TO_BRANCH',
                brid = br_id,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE
            RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;

        WHEN evt = 'ALLOCATE_TO_MERCHANT' THEN
            UPDATE registry.sb
            SET 
                sbevt = 'ALLOCATED_TO_MERCHANT',
                mid = mp_id,
                eby = e_by,
				eid = e_id,
                eat = CURRENT_TIMESTAMP
            WHERE did = d_id AND isd = FALSE
            RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;


---------------------------DEACTIVATE----------------------------


		WHEN evt='DEACTIVATE_DEVICE' THEN
				UPDATE registry.devices
				SET
					devt = 'DEVICE_DEACTIVATED',
					isa = false,
					eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
				WHERE did = d_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'DEVICE_DEACTIVATED',
                    isa = false,	
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE did = d_id AND isd = FALSE;			


		WHEN evt='DEACTIVATE_BRANCH' THEN
				UPDATE registry.branches
				SET
					brevt = 'BRANCH_DEACTIVATED',
					isa = false,
					eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
				WHERE brid = br_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'BRANCH_DEACTIVATED',
					isa = false,
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE brid = br_id AND isd = FALSE	;			
				
		WHEN evt='DEACTIVATE_VPA' THEN
				UPDATE registry.vpa
				SET
					vevt = 'VPA_DEACTIVATED',
					isa = false,
					eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
				WHERE vid = v_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'VPA_DEACTIVATED',
					isa = false,
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE vid = v_id AND isd = FALSE;
				
		WHEN evt='DEACTIVATE_MERCHANT' THEN
				UPDATE registry.merchants
				SET
					mevt = 'MERCHANT_DEACTIVATED',
					isa = false,
					eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
				WHERE mpid = mp_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'MERCHANT_DEACTIVATED',
					isa = false,
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE mid = mp_id AND isd = FALSE	;			
                
        WHEN evt='DEACTIVATE_BANK' THEN
                UPDATE registry.banks
                SET
                    bevt = 'BANK_DEACTIVATED',
                    isa = false,
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE bid = b_id;    
                UPDATE registry.sb                
                SET 
                    sbevt = 'BANK_DEACTIVATED',
                    isa = false,
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE bid = b_id AND isd = FALSE;

		WHEN evt='DELETE_VPA' THEN
				UPDATE registry.vpa
				SET
					vevt = 'VPA_DELETED',
					isd = true,
					isa = false,
					eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
				WHERE vid = v_id;
                UPDATE registry.sb
                SET 
                    sbevt = 'VPA_DELETED',
					isd = true,
					isa = false,
                    eby = e_by,
					eid = e_id,
                    eat = CURRENT_TIMESTAMP
                WHERE vid = v_id AND isd = FALSE;

        WHEN evt='REALLOCATE_TO_MERCHANT' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'REALLOCATED_TO_MERCHANT', 
                    mid = mp_id,
					eby = e_by,
					eid = e_id,
					eat = CURRENT_TIMESTAMP
       			WHERE did = d_id AND isd = FALSE
            	RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;


		WHEN evt='REALLOCATE_TO_BRANCH' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'REALLOCATED_TO_BRANCH', 
                    mid = NULL,
					brid = br_id
					eby = e_by,
					eid = e_id,
					eat = CURRENT_TIMESTAMP
       			WHERE did = d_id AND isd = FALSE
            	RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;
		
        WHEN evt='REALLOCATE_TO_BANK' THEN
				UPDATE registry.sb
       			SET 
           			sbevt = 'REALLOCATED_TO_BANK', 
                   	mid = NULL,
					brid = NULL,
					bid = b_id,
 					eby = e_by,
					eid = e_id,
					eat = CURRENT_TIMESTAMP
       			WHERE did = d_id AND isd = FALSE
            	RETURNING sid, vid, did, bid, brid, mid, eat INTO id_values;
		
        ELSE
            RAISE EXCEPTION 'Unsupported event type: %', evt;
    END CASE;

    IF evt LIKE 'DEACTIVATE%' OR evt LIKE 'DELETE%'THEN
        RETURN QUERY SELECT 
            rowid, 
            1,  
            ARRAY['SUCCESS'::registry.sb_msgs],  
            ARRAY[]::text[],  
            ARRAY[]::integer[],  
            CURRENT_TIMESTAMP::timestamp;  
    ELSE
        RETURN QUERY SELECT 
            rowid, 
            1,  
            ARRAY['SUCCESS'::registry.sb_msgs],    
            headers_array,  
            ARRAY[id_values.sid, id_values.vid, id_values.did, id_values.bid, id_values.brid, id_values.mid],  
            id_values.eat::timestamp;  
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION registry.sb_iterator(
	rowid INT[],
	evt VARCHAR,
	vpa TEXT[],	
    d_id INT[],
    b_id INT[],
    br_id INT[],
	mp_id INT[],
    e_by TEXT[],
    eid INT[]
) 
RETURNS TABLE (row_id INTEGER, status INTEGER, msgs registry.sb_msgs[],id_headers TEXT[],id_values INT[],eat timestamp) AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..array_length(rowid, 1) LOOP
  
        RETURN QUERY SELECT * FROM registry.sb_validator_writer(
			rowid[i],
			evt,
            COALESCE(vpa[i],NULL),
            COALESCE(d_id[i],NULL), 
            COALESCE(b_id[i],NULL),
			COALESCE(br_id[i],NULL),
			COALESCE(mp_id[i],NULL),
            e_by[i], 
            eid[i]
        ); 
    END LOOP; 
END;
$$ LANGUAGE plpgsql;


SELECT * FROM registry.sb_iterator(
	ARRAY[1],
	'BIND_DEVICE',
	ARRAY[]::TEXT[],
	ARRAY[100]::INTEGER[],
	ARRAY[7]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY[]::INTEGER[],
	ARRAY['hanxs']::TEXT[],
	ARRAY[1]::INTEGER[]
)