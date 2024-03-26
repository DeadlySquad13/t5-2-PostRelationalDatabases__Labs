drop function get_languages(integer);
create or replace function get_languages(first_n integer)
	returns setof varchar as
	$$
	declare
		r varchar;
		counter integer;
	begin
		counter := 0;
		
		for r in select name from repository_language
			loop
				if counter < first_n then
					counter := counter + 1;
					return next r;
				end if;
			end loop;
		return;
	end
	$$
	LANGUAGE plpgsql;

select get_languages(1);