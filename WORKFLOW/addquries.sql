ALTER TABLE workflow.wfhlog ADD COLUMN sname VARCHAR;

INSERT INTO workflow.wfactions (ecode, ainfo, htype, isd, category, isvisible,vcode) VALUES
('ENABLE_SOUNDBOX', '{"endpoint":"/requests/wfhandler"}', 'api', false, 'device_actions', true,'Enable Soundbox');


INSERT INTO workflow.wfhsteps (ecode, hinfo)
VALUES
    ('ENABLE_SOUNDBOX', '[{"endpoint":"/registry/devices","sname":"Update Device"},{"endpoint":"/drouter/sb","sname":"Enable Soundbox"}]');