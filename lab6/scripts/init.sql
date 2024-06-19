DROP SCHEMA IF EXISTS lab6 CASCADE;
CREATE SCHEMA lab6;

-- В БД создать две-три связанные таблицы по теме, выданной преподавателем.
-- - RepoUser.
DROP TABLE IF EXISTS lab6.repo_user CASCADE;
CREATE TABLE lab6.repo_user (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(256)
);

INSERT INTO lab6.repo_user ( username )
VALUES ('Sasha'),
       ('Vladik'),
       ('Misha'),
       ('Vadim'),
       ('Pasha'),
       ('Vanya');

SELECT * FROM lab6.repo_user;

DROP TABLE IF EXISTS lab6.project CASCADE;
CREATE TABLE lab6.project (
    name VARCHAR(256),
	author_id integer NOT NULL,
	foreign key (author_id) references lab6.repo_user (id)
);

-- - Repository.
DROP TABLE IF EXISTS lab6.repository CASCADE;
CREATE TABLE lab6.repository (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	stars integer,
	forks integer
) inherits (lab6.project);

INSERT INTO lab6.repository ( name, stars, forks, author_id )
VALUES ('Linux', 300000, 10000, 1),
	   ('RepoAnalyzer', NULL, 10, 2),
       ('NeoVim', 2000, 1200, 3),
       ('React', 4000, 1500, 4),
       ('Vue', 3500, NULL, 5),
       ('Tinkerpop', 1000, 200, 6);

SELECT lab6.repository.id, name, stars, forks, lab6.repo_user.id as author_id, username as author_name
	FROM lab6.repository JOIN lab6.repo_user ON lab6.repository.author_id = lab6.repo_user.id;

-- - Issue.
DROP TABLE IF EXISTS lab6.issue CASCADE;
CREATE TABLE lab6.issue (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(256),
	author_id integer NOT NULL,
	foreign key (author_id) references lab6.repo_user (id),
	repository_id integer NOT NULL,
	foreign key (repository_id) references lab6.repository (id)
);

INSERT INTO lab6.issue ( title, author_id, repository_id )
VALUES ('Bad Bug', 1, 1),
       ('Cool Feature', 2, 1),
       ('Interesting Docs', 2, 1),
       ('Mega Feature', 3, 3),
       ('Hot Bug', 3, 4),
       ('Boring Docs', 4, 3);

SELECT * FROM lab6.issue;
