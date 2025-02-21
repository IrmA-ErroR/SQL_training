-- Создаём новую БД
CREATE DATABASE bank_data;

-- Подключаемся к новой БД
-- \c bank_data;

-- Создаём схему card_transactions
CREATE SCHEMA card_transactions;

-- Создаём таблицы внутри схемы card_transactions

CREATE TABLE card_transactions.customers (
    customer_id TEXT PRIMARY KEY,
    card_number BIGINT UNIQUE NOT NULL,
    card_type TEXT
);


CREATE TABLE card_transactions.merchants (
    merchant_id BIGINT PRIMARY KEY,
    merchant TEXT UNIQUE NOT NULL,
    merchant_category TEXT NOT NULL,
    merchant_type TEXT NOT NULL,
    high_risk_merchant BOOLEAN NOT NULL
);

select *
from card_transactions.merchants ;


CREATE TABLE card_transactions.devices (
	device_id BIGINT PRIMARY key,
    device_fingerprint text not NULL,
    device TEXT NOT NULL
);

select *
from devices d ;


CREATE TABLE card_transactions.transactions (
    transaction_id TEXT PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    transaction_hour INT,
    weekend_transaction BOOLEAN,
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT NOT NULL,
    customer_id TEXT REFERENCES card_transactions.customers(customer_id) ON DELETE CASCADE,
    merchant_id INT REFERENCES card_transactions.merchants(merchant_id) ON DELETE CASCADE,
    device_id BIGINT REFERENCES card_transactions.devices(device_id) ON DELETE CASCADE,
    card_present BOOLEAN,
    distance_from_home BOOLEAN,
    ip_address TEXT
);

select *
from card_transactions.transactions t ;


CREATE TABLE card_transactions.velocity_metrics (
    transaction_id TEXT PRIMARY KEY REFERENCES card_transactions.transactions(transaction_id) ON DELETE CASCADE,
    num_transactions INT,
    total_amount double precision,
    unique_merchants INT,
    unique_countries INT,
    max_single_amount double precision
);


CREATE TABLE card_transactions.fraud_status (
    transaction_id TEXT PRIMARY KEY REFERENCES card_transactions.transactions(transaction_id) ON DELETE CASCADE,
    is_fraud BOOLEAN NOT NULL
);
