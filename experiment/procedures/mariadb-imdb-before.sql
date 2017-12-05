drop procedure if exists ksc2017_s2_mariadb;
DELIMITER //
create procedure ksc2017_s2_mariadb(in start_year int, in end_year int, in gap_in int) BEGIN
declare cnt int;
declare year_cnt int default start_year;
declare gap int default gap_in;
declare loop_cnt int;
set loop_cnt = 0;

CREATE TEMPORARY TABLE res_out (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);

for_loop: LOOP
  select concat('loop cnt is ', loop_cnt);
  IF year_cnt > end_year THEN
    LEAVE for_loop;
  END IF;

  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between start_year and start_year + gap GROUP BY t.production_year);
  select count(*) into cnt from res1;
  select cnt;

  IF loop_cnt = 0 THEN
    insert into res_out (select * from res1);
  END IF;
  IF cnt > 0 THEN
    select concat('count is ', cnt);

    CREATE TEMPORARY TABLE tmp (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);

    insert into tmp (
      select * from res1 where from_company in (select from_company from res_out)
    );

    truncate res_out;
    insert into res_out (select * from tmp);
    drop temporary table tmp;
    set gap = gap + 2;
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
    LEAVE for_loop;
  END IF;   

  set loop_cnt = loop_cnt + 1;
  DROP TEMPORARY TABLE res1;
  SET year_cnt = year_cnt + 1;
  ITERATE for_loop;
END LOOP;

SELECT * FROM res_out;

drop temporary table res_out;

END //
DELIMITER ;

call ksc2017_s2_mariadb(1990, 2010, 1);