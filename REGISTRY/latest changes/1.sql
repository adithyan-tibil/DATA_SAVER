


-- ALTER TYPE registry.sb_msgs ADD VALUE 'BANK_NOT_ALLOCATED';


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

			IF EXISTS (SELECT 1 FROM registry.sb WHERE did = d_id AND bid IS NULL AND isd = FALSE) THEN
				messages := array_append(messages, 'BANK_NOT_ALLOCATED'::registry.sb_msgs);
            END IF;
		
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
            		messages := array_append(messages, 'BANK_BRANCH_UNMATCHED_BID'::registry.sb_msgs);
        		END IF;
    		END IF;

		------------------------------------------ALLOCATE_TO_MERCHANT--------------------------------------------------		


        WHEN evt='ALLOCATE_TO_MERCHANT' THEN

			IF EXISTS ( SELECT 1 FROM registry.sb WHERE did = d_id AND (bid IS NULL OR brid IS NULL OR vid IS NULL) ) THEN
                messages := array_append(messages, 'UNABLE_TO_ALLOCATE'::registry.sb_msgs);
            END IF;
			
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
