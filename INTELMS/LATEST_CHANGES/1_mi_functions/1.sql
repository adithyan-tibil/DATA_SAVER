-- ===========================
-- DEVICE CALCULATOR ITERATORS
-- ===========================

CREATE OR REPLACE FUNCTION intel.mi_incount_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    result := intel.mc_incount_incrementer();
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_incount_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    result := intel.mc_incount_decrementer();
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_bdcount_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    result := intel.mc_bdcount_incrementer(bid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_bdcount_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    result := intel.mc_bdcount_decrementer(bid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_brdcount_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_brdcount_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_brdcount_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_brdcount_decrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_mdcount_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_mdcount_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_mdcount_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_mdcount_decrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ===========================
-- BANK AND BRANCH CALCULATORS
-- ===========================

CREATE OR REPLACE FUNCTION intel.mi_bank_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    result := intel.mc_bank_incrementer(bid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_branch_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_branch_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ===========================
-- MERCHANT CALCULATORS
-- ===========================

CREATE OR REPLACE FUNCTION intel.mi_merchant_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_merchant_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_merchant_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_merchant_decrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ===========================
-- DEVICE ISSUES
-- ===========================

CREATE OR REPLACE FUNCTION intel.mi_di_open_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_di_open_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_di_open_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_di_open_decrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_di_closed_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_di_closed_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ===========================
-- DEVICE REQUESTS
-- ===========================

CREATE OR REPLACE FUNCTION intel.mi_dr_open_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_dr_open_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_dr_open_decrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_dr_open_decrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION intel.mi_dr_closed_incrementer(p_input JSON[])
RETURNS TABLE(row_id INT, msg TEXT, status INT) AS $$
DECLARE
  row JSON;
  bid INT;
  brid INT;
  result INT;
BEGIN
  FOREACH row IN ARRAY p_input LOOP
    bid := (row->>'bid')::INT;
    brid := (row->>'brid')::INT;
    result := intel.mc_dr_closed_incrementer(bid, brid);
    RETURN QUERY SELECT (row->>'row_id')::INT, CASE WHEN result = 1 THEN 'metric success' ELSE 'metric failed' END, result;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
