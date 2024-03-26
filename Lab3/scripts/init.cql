-- cqlsh

CREATE KEYSPACE IF NOT EXISTS ran WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1};

USE ran;

DROP TABLE IF EXISTS ran.github_user;
CREATE TABLE IF NOT EXISTS ran.github_user (
    id uuid,
    username text,
    password text,
    is_admin boolean,
    PRIMARY KEY (id)
);

// insert + batch
BEGIN BATCH
    INSERT INTO ran.github_user (id, username, password, is_admin) VALUES (now(), 'username1', 'password1', true);
    INSERT INTO ran.github_user (id, username, password, is_admin) VALUES (now(), 'username2', 'password2', false);
    INSERT INTO ran.github_user (id, username, password, is_admin) VALUES (now(), 'username3', 'password3', false);
APPLY BATCH;

// ttl
INSERT INTO ran.github_user (id, username, password, is_admin) VALUES (now(), 'username4', 'password4', false) USING TTL 20;

// editable
INSERT INTO user (id, username, password, is_admin) VALUES (137fd010-d1c5-11ee-9c2a-27a45ff9c0f1, 'editable', 'editable', true);
UPDATE ran.user SET username='edited', password='edited', is_admin=false WHERE id=137fd010-d1c5-11ee-9c2a-27a45ff9c0f1;
delete from ran.user where id=137fd010-d1c5-11ee-9c2a-27a45ff9c0f1;

// editable using ttl. null after 15sec
INSERT INTO user (id, username, password, is_admin) VALUES (137fd010-d1c5-11ee-9c2a-27a45ff9c0f1, 'editable', 'editable', true);
UPDATE ran.user USING TTL 15 SET username='edited' WHERE id=137fd010-d1c5-11ee-9c2a-27a45ff9c0f1;
delete from ran.user where id=137fd010-d1c5-11ee-9c2a-27a45ff9c0f1;

// ALLOW FILTERING
SELECT * FROM ran.user WHERE username='username1';
SELECT * FROM ran.user WHERE username='username1' ALLOW FILTERING;

// index
create index usernameIndex on ran.user (username);
SELECT * FROM ran.user WHERE username='username1';
drop index usernameIndex;

// clustering
DROP TABLE IF EXISTS ran.api_resp;
CREATE TABLE IF NOT EXISTS ran.api_resp (
    id timeuuid,
    code text,
    length float,
    PRIMARY KEY (code, id)
-- id класстерный ключ              // группировка данных внутри узла
-- cf_rating распределительный ключ // распределение данных по узлам
) WITH default_time_to_live = 120 and CLUSTERING ORDER BY (id DESC);

// alter table
ALTER TABLE ran.api_resp DROP length;
ALTER TABLE ran.api_resp ADD length float;
ALTER TABLE ran.api_resp ALTER length TYPE double;
ALTER TABLE ran.api_resp RENAME length TO content_length;

BEGIN BATCH 
    INSERT INTO ran.api_resp (id, code, length) VALUES (now(), '5XX', 100);
    INSERT INTO ran.api_resp (id, code, length) VALUES (now(), '2XX', 200);
    INSERT INTO ran.api_resp (id, code, length) VALUES (now(), '2XX', 300);
APPLY BATCH;

SELECT * FROM ran.api_resp;
SELECT * FROM ran.api_resp WHERE code='5XX';

// delete all
TRUNCATE ran.api_resp;

// агрегатные функции
SELECT COUNT(*) FROM ran.user;
SELECT MAX(id) FROM ran.user;

// clustering
DROP TABLE IF EXISTS ran.api_resp;
CREATE TABLE IF NOT EXISTS ran.api_resp (
    id uuid,
    code text,
    length float,
    PRIMARY KEY (code, length)
);
// сортировка
BEGIN BATCH 
    INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '5XX', 200);
    INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '5XX', 400);
    INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '5XX', 80);
    INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '2XX', 200);
    INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '2XX', 300);
    INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '2XX', 250);
APPLY BATCH;

select * from ran.api_resp where code = '2XX' order by length desc;
select * from ran.api_resp where code = '5XX' order by length asc;

-- групировка

select code, AVG(length) from ran.api_resp group by code;

-- матеиализированное представление

// materialized_views_enabled: true - тока с вольюмом на /var/lib/cassandra/cassandra.yml
CREATE MATERIALIZED VIEW IF NOT EXISTS view_ids_ok as
select code, id from ran.api_resp where id is not null and code = '2XX'
PRIMARY KEY (id);

select * from view_ids_ok;

// update if
select * from ran.api_resp;
update ran.api_resp set id = uuid() where code = '4XX' and length = 200;
select * from ran.api_resp;
delete from ran.api_resp where code = '4XX' and length = 200 if exists;
update ran.api_resp set id = uuid() where code = '4XX' and length = 200 if exists;
select * from ran.api_resp;
