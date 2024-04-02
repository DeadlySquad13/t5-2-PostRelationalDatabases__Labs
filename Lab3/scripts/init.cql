-- cqlsh

-- ran = RepoAnalyzer
CREATE KEYSPACE IF NOT EXISTS ran WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1};

USE ran;

DROP TABLE IF EXISTS ran.repository_language;
CREATE TABLE IF NOT EXISTS ran.repository_language (
    id uuid,
    name text,
    usage int,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS ran.repository_contributor;
CREATE TABLE IF NOT EXISTS ran.repository_contributor (
    id uuid,
    name text,
    avatar_url text,
    profile_url text,
    contributions int,
    PRIMARY KEY (name, id) // name - распределительный, id - кластерный ключ
);

DROP TABLE IF EXISTS ran.repository;
CREATE TABLE IF NOT EXISTS ran.repository (
    id uuid,
    name text,
    description text,
    author_id uuid,
    language_id uuid,
    start int,
    forks int,
    issues int,
    PRIMARY KEY (id)
);

// delete all
TRUNCATE ran.repository;

// insert + batch
BEGIN BATCH
    INSERT INTO ran.repository_contributor (id, name, avatar_url, profile_url, contributions) VALUES (now(), 'sasha', 'https://github.com/sasha/avatar', 'https://github.com/sasha', 2);
    INSERT INTO ran.repository_contributor (id, name, avatar_url, profile_url, contributions) VALUES (now(), 'misha', 'https://github.com/misha/avatar', 'https://github.com/misha', 30);
    INSERT INTO ran.repository_contributor (id, name, avatar_url, profile_url, contributions) VALUES (now(), 'grisha', 'https://github.com/grisha/avatar', 'https://github.com/grisha', 33);
APPLY BATCH;

SELECT * FROM ran.repository_contributor;

BEGIN BATCH
    INSERT INTO ran.repository_language (id, name, usage) VALUES (now(), 'C++', 10);
    INSERT INTO ran.repository_language (id, name, usage) VALUES (now(), 'C#', 22);
    INSERT INTO ran.repository_language (id, name, usage) VALUES (now(), 'Python', 80);
    INSERT INTO ran.repository_language (id, name, usage) VALUES (now(), 'Python2', 12);
    INSERT INTO ran.repository_language (id, name, usage) VALUES (now(), 'Temporary', 22) USING TTL 2;
APPLY BATCH;

// Insert with specific id to later reference it.
// TTL
INSERT INTO repository_language (id, name, usage) VALUES (137fd010-d1c5-11ee-9c2a-27a45ff9c0f1, 'Python1', 0) USING TTL 15;

SELECT * FROM ran.repository_language;

// DELETE FROM ran.repository_language where name='Python2';

// SELECT * FROM ran.repository_language;

UPDATE repository_language SET name='PythonMegaCool' WHERE id=137fd010-d1c5-11ee-9c2a-27a45ff9c0f1;
SELECT * FROM ran.repository_language;

delete from repository_language where id=137fd010-d1c5-11ee-9c2a-27a45ff9c0f1;

SELECT * FROM repository_language;

SELECT * FROM repository_contributor WHERE name='misha';

SELECT * FROM repository_language WHERE name='Python' ALLOW FILTERING;

CREATE INDEX repository_language_index on repository_language (name);
DROP INDEX repository_language_index;

// Проекция.
SELECT name from repository_contributor;

// Агрегатные функции.
SELECT name, max(contributions) from repository_contributor;
SELECT count(*) from repository_contributor;

// Сортировка.
SELECT * FROM repository_contributor ORDER BY contributions;

// Группировка.
DROP TABLE IF EXISTS ran.repository_comment;
CREATE TABLE IF NOT EXISTS ran.repository_comment (
    id uuid,
    user_name text,
    message text,
    likes int,
    PRIMARY KEY (user_name, id)
);

BEGIN BATCH
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'misha', 'I am Misha', 10);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'misha', 'I like sasha!', 22);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'misha', 'I like spamming!', 80);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'grisha', 'I am Grisha!', 12);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'sasha', 'I am Sasha', 42);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'sasha', 'I like Misha', 20);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'maria', 'I am Maria', 32);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'maria', 'I am Maria', 0);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'maria', 'I am Maria', 0);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'maria', 'I am Maria', 0);
    INSERT INTO ran.repository_comment (id, user_name, message, likes) VALUES (now(), 'maria', 'I am Maria', 0);
APPLY BATCH;

// ???
SELECT user_name, SUM(likes) FROM repository_comment where user_name in ('misha', 'grisha', 'sasha') GROUP BY user_name;

// Материализованное представление.
// SELECT message FROM repository_comment WHERE likes > 0 ALLOW FILTERING;
// DROP MATERIALIZED VIEW IF EXISTS view_comment_relevant;
CREATE MATERIALIZED VIEW IF NOT EXISTS view_comment_relevant AS SELECT message FROM repository_comment WHERE likes > 0
    PRIMARY KEY (user_name, id);

// Использование IF.
DELETE FROM ran.repository_comment where user_name='masha' IF EXISTS;

// SELECT * FROM repository_language WHERE name='Python';

// // index
// create index usernameIndex on ran.user (username);
// SELECT * FROM ran.user WHERE username='username1';
// drop index usernameIndex;

// // clustering
// DROP TABLE IF EXISTS ran.api_resp;
// CREATE TABLE IF NOT EXISTS ran.api_resp (
//     id timeuuid,
//     code text,
//     length float,
//     PRIMARY KEY (code, id)
// -- id класстерный ключ              // группировка данных внутри узла
// -- cf_rating распределительный ключ // распределение данных по узлам
// ) WITH default_time_to_live = 120 and CLUSTERING ORDER BY (id DESC);

// // alter table
// ALTER TABLE ran.api_resp DROP length;
// ALTER TABLE ran.api_resp ADD length float;
// ALTER TABLE ran.api_resp ALTER length TYPE double;
// ALTER TABLE ran.api_resp RENAME length TO content_length;

// BEGIN BATCH 
//     INSERT INTO ran.api_resp (id, code, length) VALUES (now(), '5XX', 100);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (now(), '2XX', 200);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (now(), '2XX', 300);
// APPLY BATCH;

// SELECT * FROM ran.api_resp;
// SELECT * FROM ran.api_resp WHERE code='5XX';


// // агрегатные функции
// SELECT COUNT(*) FROM ran.user;
// SELECT MAX(id) FROM ran.user;

// // clustering
// DROP TABLE IF EXISTS ran.api_resp;
// CREATE TABLE IF NOT EXISTS ran.api_resp (
//     id uuid,
//     code text,
//     length float,
//     PRIMARY KEY (code, length)
// );
// // сортировка
// BEGIN BATCH 
//     INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '5XX', 200);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '5XX', 400);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '5XX', 80);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '2XX', 200);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '2XX', 300);
//     INSERT INTO ran.api_resp (id, code, length) VALUES (uuid(), '2XX', 250);
// APPLY BATCH;

// select * from ran.api_resp where code = '2XX' order by length desc;
// select * from ran.api_resp where code = '5XX' order by length asc;

// -- групировка

// select code, AVG(length) from ran.api_resp group by code;

// -- матеиализированное представление

// // materialized_views_enabled: true - тока с вольюмом на /var/lib/cassandra/cassandra.yml
// CREATE MATERIALIZED VIEW IF NOT EXISTS view_ids_ok as
// select code, id from ran.api_resp where id is not null and code = '2XX'
// PRIMARY KEY (id);

// select * from view_ids_ok;

// // update if
// select * from ran.api_resp;
// update ran.api_resp set id = uuid() where code = '4XX' and length = 200;
// select * from ran.api_resp;
// delete from ran.api_resp where code = '4XX' and length = 200 if exists;
// update ran.api_resp set id = uuid() where code = '4XX' and length = 200 if exists;
// select * from ran.api_resp;
