CREATE OR REPLACE FUNCTION get_row_var(user_id integer) RETURNS text
	AS
	$$
		DECLARE
			var_row public."repository_contributor"%rowtype; -- Объявление переменной
		BEGIN
			SELECT * INTO var_row FROM public."repository_contributor" WHERE id = user_id;
			-- Присвоение переменной значения строки таблицы
			IF NOT FOUND THEN
				RAISE EXCEPTION 'Пользователь c id % не найден', user_id;
			END IF;
			RETURN var_row.name || ', avatar: ' || var_row.avatar_url || ', profile: ' ||
				var_row.profile_url || ', contributions: ' || var_row.contributions;
		END
	$$
	LANGUAGE plpgsql;
	
SELECT * FROM get_row_var(1)