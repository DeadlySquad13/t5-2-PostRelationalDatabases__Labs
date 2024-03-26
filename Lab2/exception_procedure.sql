-- хранимая процедура
-- Создать хранимую процедуру, содержащую запросы, вызов и перехват исключений. 
-- Вызвать процедуру из окна запроса. Проверить перехват и создание исключений.
create or replace procedure delete_repo(repoid int) as
	$$
	declare repo_name varchar(256);
	begin
		select name into repo_name from repository where id=repoid;
		if repo_name is NULL then
			raise exception using errcode='E0001', hint='Call with different id or add new item with specified id', message='No repo with this id';
		else
			EXECUTE format('delete from repository where name = %I;', repo_name);
		end if;
	end;
	$$
	LANGUAGE plpgsql;

call delete_repo(322)