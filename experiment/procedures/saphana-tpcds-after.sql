create or replace procedure "ksc2017_s1_loop" (IN start_year integer, IN end_year integer, OUT first_half_year "TPC".FIRST_HALF , OUT second_half_year "TPC".SECOND_HALF)
AS BEGIN

declare year_cnt integer;
declare month_cnt integer;
declare cnt_web integer;
declare cnt_store integer;
declare cnt_catalog integer;

web_c2_ws = select ws.ws_item_sk , ws.ws_quantity , ws.ws_net_paid , ws_order_number, ws_net_profit, ws_sold_date_sk from web_sales ws  where ws.ws_net_profit > 1 and ws.ws_net_paid > 0 and ws.ws_quantity > 0;
web_c2_wr = select wr.wr_return_quantity, wr.wr_return_amt , wr_order_number, wr_item_sk  from web_returns wr ;
cat_c2_cs = select cs.cs_item_sk, cs.cs_quantity, cs.cs_net_paid , cs.cs_sold_date_sk, cs.cs_order_number from catalog_sales cs where cs.cs_net_profit > 1 and cs.cs_net_paid > 0 and cs.cs_quantity > 0;
cat_c2_cr = select cr.cr_return_quantity, cr.cr_return_amount ,  cr.cr_order_number , cr.cr_item_sk from catalog_returns cr ;
store_c2_sts = select sts.ss_item_sk , sts.ss_quantity, sts.ss_net_paid , sts.ss_ticket_number, sts.ss_sold_date_sk from store_sales sts where sts.ss_net_profit > 1 and sts.ss_net_paid > 0 and sts.ss_quantity > 0 ;
store_c2_sr = select  sr.sr_return_quantity , sr.sr_return_amt, sr.sr_ticket_number , sr.sr_item_sk from store_returns sr ;

FOR year_cnt in :start_year .. :end_year DO
   -- FOR month_cnt in 1 .. 12 DO
      -- loop 1
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 1;
      IF 1 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 1 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 2
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 2;
      IF 2 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 2 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 3
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 3;
      IF 3 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 3 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 4
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 4;
      IF 4 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 4 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 5
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 5;
      IF 5 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 5 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 6
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 6;
      IF 6 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 6 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 7
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 7;
      IF 7 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 7 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 8
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 8;
      IF 8 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 8 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 9
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 9;
      IF 9 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 9 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 10
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy =10;
      IF 10 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 10 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 11
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 11;
      IF 11 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 11 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


      -- loop 12
      _date = select d_date_sk, d_year, d_moy from date_dim  where d_year = :year_cnt and d_moy = 12;
      IF 12 < 7 THEN -- 상반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
 
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            first_half_year = select * from :first_half_year union select * from :res_per_month;
         END IF;
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;                
      END IF;
      IF 12 > 7 THEN -- 하반기
         web_c2 = select ws.ws_item_sk as item, (cast(sum(coalesce(wr.wr_return_quantity,0)) as dec(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as dec(15,4) )) as return_ratio, (cast(sum(coalesce(wr.wr_return_amt, 0)) as dec(15, 4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as dec(15, 4) )) as currency_ratio  from :web_c2_ws ws left outer join :web_c2_wr wr on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk), :_date dd where wr.wr_return_amt > 10000 and ws.ws_sold_date_sk = d_date_sk group by ws.ws_item_sk ;      
         cat_c2 = select  cs.cs_item_sk as item , (cast(sum(coalesce(cr.cr_return_quantity, 0)) as dec(15,4))/ cast(sum(coalesce(cs.cs_quantity, 0)) as dec(15,4) )) as return_ratio ,(cast(sum(coalesce(cr.cr_return_amount,   0)) as dec(15,   4))/ cast(sum(coalesce(cs.cs_net_paid,   0)) as dec(15,4) )) as currency_ratio  from  :cat_c2_cs cs left outer join  :cat_c2_cr cr  on (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk), :_date dd where cr.cr_return_amount > 10000 and cs.cs_sold_date_sk = dd.d_date_sk  group by cs.cs_item_sk;
         store_c2 = select sts.ss_item_sk as item ,(cast(sum(coalesce(sr.sr_return_quantity,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_quantity,   0)) as dec(15,   4) )) as return_ratio ,   (cast(sum(coalesce(sr.sr_return_amt,   0)) as dec(15,   4))/cast(sum(coalesce(sts.ss_net_paid,   0)) as dec(15,   4) )) as currency_ratio            from         :store_c2_sts sts           left outer join            :store_c2_sr sr            on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)            ,   :_date dd            where sr.sr_return_amt > 10000 and sts.ss_sold_date_sk = dd.d_date_sk             group by sts.ss_item_sk ;     
         
         web_c1 = (select item ,return_ratio ,currency_ratio , rank() over (order by return_ratio) as return_rank ,   rank() over (      order by currency_ratio) as currency_rank  from :web_c2 in_web );
         cat_c1 = (select item ,   return_ratio ,   currency_ratio ,rank() over ( order by return_ratio) as return_rank ,   rank() over (order by currency_ratio) as currency_rank from :cat_c2 in_cat );
         store_c1 = select item ,return_ratio ,currency_ratio ,rank() over (   order by return_ratio) as return_rank , rank() over ( order by currency_ratio) as currency_rank from :store_c2 in_store ;
         web_calc = select top 100 'web' as channel, web.item ,   web.return_ratio ,web.return_rank ,   web.currency_rank from :web_c1 web where ( web.return_rank <= 10 or web.currency_rank <= 10 );
         
         cat_calc =  select 'catalog' as channel ,catalog.item ,catalog.return_ratio ,catalog.return_rank ,catalog.currency_rank from :cat_c1 catalog where ( catalog.return_rank <= 10 or catalog.currency_rank <=10 )  ;
         
         store_calc = select 'store' as channel ,store.item ,   store.return_ratio , store.return_rank ,store.currency_rank  from :store_c1 store where ( store.return_rank <= 10 or store.currency_rank <= 10 ) ;
         
         select count(*) into cnt_store from :store_calc;
         select count(*) into cnt_catalog from :cat_calc;
         select count(*) into cnt_web from :web_calc;         
         IF (:cnt_store > 0) AND (:cnt_catalog > 0) AND (:cnt_web > 0) THEN   
            res_per_month = select * from :web_calc union select * from :cat_calc union select * from :store_calc order by 1,4,5;
            second_half_year = select * from :second_half_year union select * from :res_per_month;
         END IF;   
         delete from cnt_w;
         delete from cnt_s;
         delete from cnt_c;            
      END IF;


   -- END FOR;
   select count(*) from :first_half_year;
   select count(*) from :second_half_year;
END FOR;
END