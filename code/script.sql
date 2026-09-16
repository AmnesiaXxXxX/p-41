-- Инструкция для запуска всей этой шляпы
--
-- 1. docker compose up -d
--      Дожидаетесь запуска всех сервисов
--      PGAdmin можно открыть по http://localhost:4500
--      Логин: postgres@postgres.postgres 
--      Пароль: postgres
--      По стандарту пароль и логин берутся из файла .env там поля подписаны
-- 2. docker compose exec -it db psql -U postgres -d db
--      Подключение к бд
--          -U -- Пользователь
--          -d -- База данных к которой подключаемся
-- 3. Если всё ок, то вы должны увидеть что то такое
--          psql (16.15)
--          Type "help" for help.
--          db=# 
--      Сюда уже можно вставлять код ниже
--      


CREATE EXTENSION IF NOT EXISTS pgcrypto;

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


-- Дешифровка пароля

/* SELECT 
	username, 
	pgp_sym_decrypt(
		password::bytea, 
		'SECRET_KEY', 
		'compress-algo=1, cipher-algo=aes256'
	) as password
FROM users; */