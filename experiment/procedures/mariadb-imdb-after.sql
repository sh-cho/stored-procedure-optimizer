drop procedure if exists ksc2017_s2_mariadb;
DELIMITER //
create procedure ksc2017_s2_mariadb() BEGIN
declare cnt int;
declare gap int default gap_in;

CREATE TEMPORARY TABLE res_out (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);

  --1999
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 1999 and 2000 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;


  --2000
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2000 and 2001 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2001
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2001 and 2002 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2002
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2002 and 2003 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2003
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2003 and 2004 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2004
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2004 and 2005 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2005
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2005 and 2006 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2006
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2006 and 2007 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2007
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2007 and 2008 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2008
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2008 and 2009 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

  --2009
  CREATE TEMPORARY TABLE res1 (from_company varchar(50), movie_link_type varchar(32), non_polish_sequel_movie varchar(50), y int);
   
  insert into res1 (SELECT MIN(cn.name) AS from_company, MIN(lt.link) AS movie_link_type, MIN(t.title) AS non_polish_sequel_movie, t.production_year AS y FROM company_name AS cn,  company_type AS ct, keyword AS k, link_type AS lt, movie_companies AS mc, movie_keyword AS mk, movie_link AS ml, title AS t WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%') AND ct.kind ='production companies' AND k.keyword ='sequel' AND lt.link LIKE '%follow%' AND mc.note IS NULL AND lt.id = ml.link_type_id AND ml.movie_id = t.id AND t.id = mk.movie_id AND mk.keyword_id = k.id AND t.id = mc.movie_id AND mc.company_type_id = ct.id AND mc.company_id = cn.id AND ml.movie_id = mk.movie_id AND ml.movie_id = mc.movie_id AND mk.movie_id = mc.movie_id AND t.production_year between 2009 and 2010 GROUP BY t.production_year);
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
  END IF;
  IF cnt = 0 THEN
    DROP TEMPORARY TABLE res1;
  END IF;   

  DROP TEMPORARY TABLE res1;

SELECT * FROM res_out;

drop temporary table res_out;

END //
DELIMITER ;

call ksc2017_s2_mariadb();