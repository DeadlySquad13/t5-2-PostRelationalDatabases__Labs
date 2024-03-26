CREATE OR REPLACE FUNCTION loop_to_100(new_int integer)
	RETURNS integer AS
	$$
	DECLARE
		steps integer := 0;
	BEGIN
		LOOP
			IF new_int >= 100 THEN
				EXIT; -- выход из цикла
			END IF;
			-- здесь производятся вычисления
			new_int := new_int + 1;
			steps := steps + 1;
		END LOOP;
		RETURN steps;
	END
	$$
	LANGUAGE plpgsql;
	
SELECT * FROM loop_to_100(20);