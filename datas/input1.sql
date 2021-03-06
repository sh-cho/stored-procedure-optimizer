CREATE PROCEDURE input1()
AS BEGIN
	declare cnt integer;
	declare year_cnt integer;
	declare gap integer;
	declare loop_cnt integer;
	loop_cnt := 0;
	gap := 1;

	FOR year_cnt in :start_year .. :end_year DO
		res1 = SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between :start_year and :start_year + :gap GROUP BY t.production_year;

		select count(*) into cnt from :res1;

		IF :loop_cnt = 0 THEN
			res = select * from :res1;
		END IF;

		IF :cnt > 0 THEN
			res = select * from :res1 intersect select * from :res;
		END IF;

		IF :cnt = 0 THEN
			break;
		END IF;   
		
		loop_cnt := :loop_cnt + 1;
	END FOR;
END