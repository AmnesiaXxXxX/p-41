CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP DATABASE IF EXISTS db;
CREATE DATABASE db WITH OWNER postgres;
-- подключение к бд
\c db

-- Блок ниже можно выполнять где угодно

DROP TABLE IF EXISTS generated_users;

CREATE TEMP TABLE generated_users (
	username TEXT,
	password TEXT,
	database TEXT
);

INSERT INTO generated_users (username, database, password )
SELECT 
	'user' || i,
	'DB' || i,
	left(encode(gen_random_bytes(5), 'hex'), 5)
FROM generate_series(1,10) as i;



-- Код ниже выполнять в psql также отдельно

SELECT 
	format(
		'DROP DATABASE IF EXISTS %I;',
		database
	)
FROM generated_users
UNION ALL
SELECT 
	format(
		'DROP ROLE IF EXISTS %I;',
		username
	)
FROM generated_users
UNION ALL
SELECT 
	format(
		'CREATE ROLE %I LOGIN PASSWORD %L;',
		username,
		password
	)
FROM generated_users
UNION ALL
SELECT 
	format(
		'CREATE DATABASE %I WITH OWNER %I;',
		database,
		username
	)
FROM generated_users
UNION ALL
SELECT 
	format(
		'REVOKE CONNECT ON DATABASE %I FROM PUBLIC;',
		database
	)
FROM generated_users
UNION ALL
SELECT 
	format(
		'GRANT CONNECT ON DATABASE %I TO %I;',
		database,
		username
	)
FROM generated_users;
\gexec

-- Блок ниже можно выполнять где угодно

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	username TEXT,
	password TEXT
);

INSERT INTO users (username, password)
SELECT 
	username, 
	pgp_sym_encrypt(
		password, 
		'SECRET_KEY', 
		'compress-algo=1, cipher-algo=aes256'
	) 
FROM generated_users;
