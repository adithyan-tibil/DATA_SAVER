CREATE OR REPLACE FUNCTION registry.onboard_vpa(
    rowid INT[],
    vpa_name TEXT[],
    d_name TEXT[],
    b_name TEXT[],
    event_bys TEXT[],
    eids INT[]
)
RETURNS TABLE (
    row_ids INTEGER, 
    final_status INTEGER, 
    response VARCHAR, 
    steps TEXT[], 
    create_vpa_status INTEGER, 
    create_vpa_response registry.vpa_msgs[][], 
    bind_device_status INTEGER, 
    bind_device_response registry.sb_msgs[][]
) AS
$$
DECLARE
    f_status INTEGER := 0;
BEGIN
    -- Temporary table for vpa_iterator result
    CREATE TEMP TABLE temp_vpa_result (
        row_ids INTEGER, 
        create_status INTEGER,
        vid VARCHAR,
        vpa_msgs registry.vpa_msgs[]
    ) ON COMMIT DROP;
    
    -- Store the result from registry.vpa_iterator
    INSERT INTO temp_vpa_result (row_ids, create_status, vid, vpa_msgs)
    SELECT row_id, status, vid, msg FROM registry.vpa_iterator(
        rowid,
        vpa_name,
        d_name,
        b_name,
        event_bys,
        eids
    );

    -- Temporary table for sb_iterator result
    CREATE TEMP TABLE temp_sb_result (
        row_ids INTEGER, 
        bind_status INTEGER, 
        sb_msgs registry.sb_msgs[]
    ) ON COMMIT DROP;

    -- Store the result from registry.sb_iterator
    INSERT INTO temp_sb_result (row_ids, bind_status, sb_msgs)
    SELECT row_id, status, msgs FROM registry.sb_iterator(
        rowid,
        'BIND_DEVICE',
        vpa_name,    
        d_name,
        ARRAY[]::TEXT[],
        ARRAY[]::TEXT[],
        ARRAY[]::TEXT[],
        event_bys,
        eids
    );

    -- Determine final status
    -- SELECT INTO f_status 
    --     CASE 
    --         WHEN EXISTS (SELECT 1 FROM temp_vpa_result WHERE create_status = 0) OR 
    --              EXISTS (SELECT 1 FROM temp_sb_result WHERE bind_status = 0)
    --         THEN 0 ELSE 1 
    --     END;

    -- Return the combined result with messages from both tables
    RETURN QUERY 
    SELECT sb.row_ids,
           CASE 
           WHEN vp.create_status = 0 OR sb.bind_status = 0 THEN 0 
           ELSE 1 
       	   END AS final_status,
           vp.vid,
           ARRAY['create_vpa', 'bind_device']::TEXT[],
           vp.create_status,
           vp.vpa_msgs,
           sb.bind_status, 
           sb.sb_msgs
    FROM temp_sb_result sb
    JOIN temp_vpa_result vp ON sb.row_ids = vp.row_ids;
    
END;
$$ LANGUAGE plpgsql;




SELECT * FROM registry.onboard_vpa(
	ARRAY[1,2],
    ARRAY['vpa_201', 'vpa11'],  
	ARRAY['device_1011','device_3334'],
	ARRAY['bank_1', 'bank_1'], 
    ARRAY['ui1', 'ip1'], 
    ARRAY[28, 28]
);












----------------------------------RESULTS


"row_ids"	"final_status"	"response"	"steps"	"create_vpa_status"	"create_vpa_response"	"bind_device_status"	"bind_device_response"
1	1	"vpa_201"	"{create_vpa,bind_device}"	1	"{SUCCESS_INSERT}"	1	"{SUCCESS}"
2	0	"vpa11"	"{create_vpa,bind_device}"	0	"{INVALID_DEVICE}"	0	"{INVALID_DEVICE,INVALID_VPA}"