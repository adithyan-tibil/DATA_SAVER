ALTER TABLE switch.payments_cache
ALTER COLUMN did TYPE VARCHAR;

ALTER TABLE switch.payments_cache
ALTER COLUMN iid TYPE VARCHAR;

ALTER TABLE switch.devices
ALTER COLUMN did TYPE VARCHAR;

ALTER TABLE switch.ins
ALTER COLUMN iid TYPE VARCHAR;