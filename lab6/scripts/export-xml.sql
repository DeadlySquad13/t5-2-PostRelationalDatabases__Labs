-- 2. В среде построения запросов PgAdmin продемонстрировать просмотр экспорт содержимого таблиц в xml в следующих вариантах:
-- - все поля —  элементы,
-- params: table, add nulls?, don't add under one tag (table)?, целевое
-- пространство имён (targetns)
select table_to_xml('lab6.repository', false, true, '');

-- - одного аттрибута
select xmlelement(name repo_name, name) from lab6.repository;
-- - все поля —  атрибуты,
select xmlelement(name repo, xmlattributes(name, author_id, id, stars, forks)) from lab6.repository;

-- - добавление корневого элемента,
-- Оборачивает каждый xmlelement в <?xml> тэг.
/* select xmlroot (
    xmlelement(name repo, xmlattributes(name, author_id, id, stars, forks)),
    version '1.1',
    standalone yes
) from lab6.repository; */

select xmlelement(
    name repositories,
    xmlagg(xmlelement(name repo, xmlattributes(name, author_id, id, stars, forks)))
) from lab6.repository;

-- - переименование строк,
select xmlelement(name repo, xmlattributes(name, author_id, id, stars as zvezdochki, forks as vilochki)) from lab6.repository;

-- - получение xml-схемы по умолчанию, o отображение значений NULL.
select table_to_xml('lab6.repository', true, false, '');


select query_to_xml('SELECT lab6.repository.id, name, stars, forks, lab6.repo_user.id as author_id, username as author_name
    FROM lab6.repository JOIN lab6.repo_user ON lab6.repository.author_id = lab6.repo_user.id',true,true,'') ;

-- Экспорт в файл.
COPY (
    select query_to_xml('SELECT lab6.repository.id, name, stars, forks, lab6.repo_user.id as author_id, username as author_name
        FROM lab6.repository JOIN lab6.repo_user ON lab6.repository.author_id = lab6.repo_user.id',true,true,'')
) TO '/xmldocs/query.xml';

COPY (
    select xmlelement(
        name repositories,
        xmlagg(xmlelement(name repo, xmlattributes(name, author_id, id, stars, forks)))
    ) from lab6.repository
) TO '/xmldocs/repositories.xml';


-- 3. В среде построения запросов создать сценарии для чтения xml из файла (взять xml документ сложной структуры, полученный ранее). На языке XPath выполнить запросы:
-- - Проверки существования данных (атрибутов, элементов и их значений);
SELECT xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml'));
SELECT xpath_exists('//repo', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')));
SELECT xpath_exists('//repo/text()', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')));
SELECT xpath_exists('//repo/@stars', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')));

-- - Извлечения данных (атрибутов, элементов и содержимого);
-- - - Элементы.
SELECT xpath('//repo', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')));

-- - - Атрибуты.
SELECT xpath('//repo/@stars', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')));

-- - - Содержимое.
SELECT xpath('//repo/text()', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')));

-- - Получения фрагмента XML.
SELECT xmlelement(
        name stars,
        xpath('//repo/@stars', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')))
    );

SELECT xmlelement(
        name stars,
        1
    )
FROM unnest(
    xpath('//repo/@stars', xmlparse(CONTENT pg_read_file('/xmldocs/repositories.xml')))
);

-- Отображение схемы.
select table_to_xml_and_xmlschema('lab6.repository', true, false, '');
