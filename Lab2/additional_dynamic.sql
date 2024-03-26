-- Доп: динамический запрос - выборка из репозиториев, параметры: имя поля и значение поля для выборки
create or replace function get_repos1(field varchar, field_value int)
	returns varchar as
	$$
	declare repo_name varchar(256);
	begin
		EXECUTE format('select name from repository where %I=$1', field)
		into repo_name
		using field_value;
		
		return repo_name;
	end;
	$$
	LANGUAGE plpgsql;


--select * from repository;
select * from get_repos1('stars', 101);