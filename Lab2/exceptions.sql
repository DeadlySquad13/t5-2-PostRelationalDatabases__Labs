-- drop function get_repo(point);
CREATE OR REPLACE FUNCTION get_repo(source_point point, max_distance double precision)
	RETURNS TABLE(repo varchar, repo_vicinity circle, distance_from_source double precision) AS
	$$
	BEGIN
		RETURN QUERY SELECT name, vicinity, @@ vicinity <-> source_point FROM public.repository
			WHERE @@ vicinity <-> source_point < max_distance
			ORDER BY id ASC;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Нет подходящих репозиториев. У всех расстояние от центра окрестности (vicinity) до % > %', $1, $2;
		END IF;
		RETURN;
	END;
	$$
	LANGUAGE plpgsql;

-- Возвращает доступные рейсы либо вызывает исключение, если их нет.
SELECT * FROM get_repo('(8,2)', 9);
--SELECT * FROM get_repo('(8,2)', 4);