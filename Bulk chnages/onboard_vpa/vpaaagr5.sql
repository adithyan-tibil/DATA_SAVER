CREATE OR REPLACE FUNCTION registry.onboard_vpa(
    rowid INT[],
    vpa_name TEXT[],
    d_name TEXT[],
    b_name TEXT[],
    event_bys TEXT[],
    eids INT[]
)
RETURNS TABLE (
    a_row_id INTEGER, 
    final_status INTEGER, 
    response VARCHAR, 
    steps TEXT[],
    step_status INTEGER[], 
    onboard_vpa_response registry.vpa_msgs[][], 
    bind_device_response registry.sb_msgs[][]
) AS
$$
DECLARE
    f_status INTEGER := 0;
BEGIN
    CREATE TEMP TABLE temp_result (
        row_ids INTEGER, 
        create_status INTEGER,
        vid VARCHAR,
        vpa_msgs registry.vpa_msgs[],
		bind_status INTEGER, 
        sb_msgs registry.sb_msgs[]
    ) ON COMMIT DROP;
    
    INSERT INTO temp_result (row_ids, create_status, vid, vpa_msgs)
    SELECT row_id, status, vid, msg FROM registry.vpa_iterator(
        rowid,
        vpa_name,
        d_name,
        b_name,
        event_bys,
        eids
    );


    UPDATE temp_result SET bind_status = sb_result.status, sb_msgs = sb_result.msgs
    FROM (
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
        )
    ) AS sb_result
    WHERE temp_result.row_ids = sb_result.row_id;
    
    RETURN QUERY 
    SELECT sb.row_ids,
           CASE 
           WHEN vp.create_status = 0 OR sb.bind_status = 0 THEN 0 
           ELSE 1 
       	   END AS final_status,
           vp.vid,
           ARRAY['ONBOARD_VPA', 'BIND_DEVICE']::TEXT[],
           ARRAY[vp.create_status, sb.bind_status],
           vp.vpa_msgs,
           sb.sb_msgs
    FROM temp_sb_result sb
    JOIN temp_vpa_result vp ON sb.row_ids = vp.row_ids;
    
END;
$$ LANGUAGE plpgsql;




SELECT * FROM registry.onboard_vpa(
	ARRAY[1,2],
    ARRAY['vpa_202', 'vpa11'],  
	ARRAY['device_5','device_3334'],
	ARRAY['bank_1', 'bank_1'], 
    ARRAY['ui1', 'ip1'], 
    ARRAY[28, 28]
);

