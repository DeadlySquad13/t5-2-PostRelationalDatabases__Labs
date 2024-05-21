DROP SCHEMA IF EXISTS lab6 CASCADE;
CREATE SCHEMA lab6;

-- В БД создать две-три связанные таблицы по теме, выданной преподавателем.
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

DROP TABLE IF EXISTS lab6.repository CASCADE;
CREATE TABLE lab6.repository (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(256),
	stars integer,
	forks integer,
	author_id integer NOT NULL,
	foreign key (author_id) references lab6.repo_user (id)
);

INSERT INTO lab6.repository ( name, stars, forks, author_id )
VALUES ('Linux', 300000, 10000, 1),
	   ('RepoAnalyzer', 14, 10, 2),
       ('NeoVim', 2000, 1200, 3),
       ('React', 4000, 1500, 4),
       ('Vue', 3500, 1250, 5),
       ('Tinkerpop', 1000, 200, 6);

-- SELECT *, author_name FROM lab6.repository JOIN ON lab6.repo_user WHERE ;
SELECT lab6.repository.id, name, stars, forks, lab6.repo_user.id as author_id, username as author_name FROM lab6.repository JOIN lab6.repo_user ON lab6.repository.author_id = lab6.repo_user.id;
