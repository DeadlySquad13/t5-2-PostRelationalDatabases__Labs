-- Inline function.
CREATE OR REPLACE FUNCTION sum_n_product_with_language (x int)
	RETURNS TABLE(name varchar, sum int, product int) AS $$
		SELECT name, $1 + usage, $1 * usage FROM repository_language;
	$$ LANGUAGE SQL;
	
SELECT * from sum_n_product_with_language(10)