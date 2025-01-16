CREATE TABLE IF NOT EXISTS registry.policies (
    pid SERIAL PRIMARY KEY,
    policy_name VARCHAR NOT NULL UNIQUE,
    policy_content TEXT NOT NULL, 
    last_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP 
);


INSERT INTO registry.policies (policy_name, policy_content)
VALUES 
    ('P&P', 'Your privacy is important to us. We are committed to protecting your personal information. This policy explains how we collect, use, and disclose your information.'),
    ('T&C', 'By using our services, you agree to be bound by the following terms and conditions. Please read them carefully.');
