CREATE OR REPLACE FUNCTION languages_max_usage(threshold integer)
	RETURNS integer AS
	$$
	DECLARE
		max_usage integer;
	BEGIN
		SELECT max(usage) into max_usage
		FROM public.repository_language
		WHERE usage > threshold;
		
		RETURN max_usage;
	END
	$$
	LANGUAGE plpgsql;
		
-- SELECT * FROM languages_max_usage();

CREATE OR REPLACE FUNCTION max_usage_language()
	RETURNS varchar AS
	$$
	DECLARE
		max_usage integer;
		repo_language varchar;
	BEGIN
		max_usage := languages_max_usage(10);
		
		SELECT name into repo_language
		FROM public.repository_language
		WHERE usage = max_usage;
		
		RETURN repo_language;
	END
	$$
	LANGUAGE plpgsql;
	
SELECT * FROM max_usage_language();