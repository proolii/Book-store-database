CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

CREATE TABLE IF NOT EXISTS users (
     id UUID PRIMARY KEY,
     email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role TEXT CHECK (role IN ('CLIENT', 'SELLER')) NOT NULL
);

CREATE TABLE IF NOT EXISTS contact_info (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    phone VARCHAR(30),
    address VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS payment_method (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('CARD', 'WALLET')) NOT NULL,
    account_number VARCHAR(255) NOT NULL
);
