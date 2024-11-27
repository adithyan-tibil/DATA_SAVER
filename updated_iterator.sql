CREATE OR REPLACE FUNCTION registry.sb_iterator_v2(
    evt VARCHAR,
    headers TEXT[], 
    data INTEGER[][]
) 
RETURNS TABLE (
    row_id INTEGER,
    status INTEGER,
    msgs registry.sb_msgs[],
    id_headers TEXT[],
    id_values INTEGER[],
    eat timestamp
) AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..array_length(data, 1) LOOP
        RETURN QUERY 
        SELECT * 
        FROM registry.sb_validator_writer(
            data[i][ARRAY_POSITION(headers, 'rowid')],
            evt ,
            COALESCE(data[i][ARRAY_POSITION(headers, 'vid')], NULL) ,
            COALESCE(data[i][ARRAY_POSITION(headers, 'did')], NULL) ,
            COALESCE(data[i][ARRAY_POSITION(headers, 'bid')], NULL) ,
            COALESCE(data[i][ARRAY_POSITION(headers, 'brid')], NULL) ,
            COALESCE(data[i][ARRAY_POSITION(headers, 'mpid')], NULL) ,
            data[i][ARRAY_POSITION(headers, 'eby')] ,
            data[i][ARRAY_POSITION(headers, 'eid')] 
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * 
FROM registry.sb_iterator_v2(
    'BOUND_DEVICE',
    ARRAY['row', 'vid', 'did','eid','eby'],
    ARRAY[
        ARRAY[1, 11, 222,1,1]::INTEGER[],
        ARRAY[2, 12, 333,1,1]::INTEGER[],
        ARRAY[3, 13, 444,1,1]::INTEGER[],
        ARRAY[4, 14, 555,1,1]::INTEGER[]
    ]::INTEGER[]
);


-- registryMS