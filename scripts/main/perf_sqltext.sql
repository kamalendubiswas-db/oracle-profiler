-- Uncomment sql_text columns if you want to see sql statement caught and see if the classification is correct
@spoolhead.sql
spool results/perf_sqltext.csv

select dt
    ,cont.name as pdb_name
    ,command
    ,parsing_schema_name
    --,sql_text
    ,instance_number
    ,count(*) as cnt
from
( select  g.con_id,g.instance_number,
     to_char(begin_interval_time,'YYYY-MM-DD HH24:MI') dt,
       -- to_char(begin_interval_time,'YYYY-MM-DD AMHH:MI:SS') dt,
     case WHEN name='CREATE TABLE' AND instr(upper(TRANSLATE(dbms_lob.substr(t.SQL_TEXT,2000),chr(10)||chr(13), ' ')), 'SELECT') > 0 THEN 'ETL'
	  WHEN name='INSERT' AND instr(upper(TRANSLATE(dbms_lob.substr(t.SQL_TEXT,2000),chr(10)||chr(13), ' ')), 'SELECT') > 0 THEN 'ETL'
	  WHEN name='UPDATE' AND instr(upper(TRANSLATE(dbms_lob.substr(t.SQL_TEXT,2000),chr(10)||chr(13), ' ')), 'SELECT') > 0 THEN 'ETL'
	  WHEN name='DELETE' AND instr(upper(TRANSLATE(dbms_lob.substr(t.SQL_TEXT,2000),chr(10)||chr(13), ' ')), 'SELECT') > 0 THEN 'ETL'
	  WHEN name='INSERT' THEN 'INSERT'
	  WHEN name='UPDATE' THEN 'UPDATE'
	  WHEN name='DELETE' THEN 'DELETE'
	  WHEN name IN ('TRUNCATE TABLE','TRUCATE CLUSTER') THEN 'TRUNCATE'
	  WHEN name='UPSERT' THEN 'ETL'
	  WHEN name='SELECT' THEN 'BI/QUERY'
	  WHEN name='PL/SQL EXECUTE' THEN 'PL/SQL EXECUTE'
	  WHEN name IN ('CREATE TABLE','CREATE CLUSTER','CREATE INDEX',
				'ALTER TABLE','ALTER CLUSTER','ALTER INDEX',
				'DROP TABLE','DROP CLUSTER','DROP INDEX') THEN 'DDL/SEGMENT'
	  WHEN name IN ('CREATE MATERIALIZED VIEW','CREATE MATERIALIZED VIEW LOG','CREATE MATERIALIZED ZONEMAP',
				'ALTER MATERIALIZED VIEW','ALTER MATERIALIZED VIEW LOG','ALTER MATERIALIZED ZONEMAP',
				'DROP MATERIALIZED VIEW','DROP MATERIALIZED VIEW LOG','DROP MATERIALIZED ZONEMAP') THEN 'DDL/MVIEW'
	  WHEN name IN ('CREATE FUNCTION','CREATE PACKAGE','CREATE PACKAGE BODY','CREATE PROCEDURE','CREATE TRIGGER','CREATE TYPE','CREATE TYPE BODY','CREATE VIEW','CREATE SEQUENCE',
				'ALTER FUNCTION','ALTER PACKAGE','ALTER PACKAGE BODY','ALTER PROCEDURE','ALTER TRIGGER','ALTER TYPE','ALTER TYPE BODY','ALTER VIEW','ALTER SEQUENCE',
				'DROP FUNCTION','DROP PACKAGE','DROP PACKAGE BODY','DROP PROCEDURE','DROP TRIGGER','DROP TYPE','DROP TYPE BODY','DROP VIEW','DROP SEQUENCE') THEN 'DDL/PLSQL'
	 -- WHEN 'GRANT OBJECT' THEN 'DCL'
	 ELSE 'OTHER'
     end as command,
     name command_name,
     translate(dbms_lob.substr(t.sql_text,2000) ,chr(10)||chr(13),' ') sql_text,
     parsing_schema_name
from  CDB_HIST_SQLSTAT g
   left join CDB_HIST_SNAPSHOT s
     on (g.SNAP_ID=s.SNAP_ID)
   inner join CDB_HIST_SQLTEXT t
     on (g.SQL_ID=t.sql_id)
   inner join audit_actions aa
     on (COMMAND_TYPE = aa.ACTION)
where
    parsing_schema_name in (select username from cdb_users where oracle_maintained='N')
    and g.con_id=t.con_id
    and g.snap_id=s.snap_id
   -- and s.begin_interval_time > sysdate - 7
) sub,
(select distinct con_id, name from gv$containers) cont
where cont.con_id=sub.con_id
group by dt
,instance_number
,cont.name
, command
, parsing_schema_name
order by dt
/
spool off
exit
