CREATE OR REPLACE FUNCTION set_int_var(new_int integer)
	RETURNS integer AS
	$$
		DECLARE
			var_int integer;
		BEGIN
			var_int := new_int/2;
		RETURN var_int;
		END
	$$
	LANGUAGE plpgsql;
	
SELECT * FROM set_int_var(30);