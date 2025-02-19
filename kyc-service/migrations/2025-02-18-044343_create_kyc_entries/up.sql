-- Your SQL goes here
CREATE TABLE kyc_entries (
    id SERIAL PRIMARY KEY,
    user_email TEXT NOT NULL UNIQUE,
    identity_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
