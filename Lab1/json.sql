create table if not exists super_table (
    id SERIAL PRIMARY KEY,
    json_column JSON,
	range_column int4range
);

-- insert into super_table (json_column, range_column)
values ('{"name": "Sanya", "age": 22, "address": {"city": "New York", "state": "NY"}}', '(1, 12)');

--select * from super_table;
select lower(range_column), upper(range_column) from super_table;
