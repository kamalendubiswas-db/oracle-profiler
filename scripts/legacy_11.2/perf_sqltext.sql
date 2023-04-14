-- Uncomment sql_text columns if you want to see sql statement caught and see if the classification is correct
@spoolhead.sql
spool results/perf_sqltext.csv

SELECT
    dt,
    cont.name AS pdb_name,
    command,
    parsing_schema_name,
    instance_number,
    COUNT(*)  AS cnt
FROM
    (
        SELECT
            g.instance_number,g.dbid,
            to_char(begin_interval_time, 'YYYY-MM-DD HH24:MI') dt,
       -- to_char(begin_interval_time,'YYYY-MM-DD AMHH:MI:SS') dt,
            CASE
                WHEN name = 'CREATE TABLE' AND instr(upper(translate(dbms_lob.substr(t.sql_text,2000) , CHR(10)|| CHR(13), ' ')), 'SELECT') > 0 THEN 'ETL'
                WHEN name = 'INSERT' AND instr(upper(translate(dbms_lob.substr(t.sql_text,2000) , CHR(10) || CHR(13), ' ')), 'SELECT') > 0 THEN 'ETL'
                WHEN name = 'UPDATE' AND instr(upper(translate(dbms_lob.substr(t.sql_text,2000) , CHR(10) || CHR(13), ' ')), 'SELECT') > 0 THEN 'ETL'
                WHEN name = 'DELETE' AND instr(upper(translate(dbms_lob.substr(t.sql_text,2000) , CHR(10) || CHR(13), ' ')), 'SELECT') > 0 THEN 'ETL'
                WHEN name = 'INSERT' THEN 'INSERT' 
                WHEN name = 'UPDATE' THEN 'UPDATE'
                WHEN name = 'DELETE' THEN 'DELETE'
                WHEN name IN ( 'TRUNCATE TABLE', 'TRUCATE CLUSTER' ) THEN  'TRUNCATE'
                WHEN name = 'UPSERT'         THEN 'ETL'
                WHEN name = 'SELECT'         THEN 'BI/QUERY'
                WHEN name = 'PL/SQL EXECUTE' THEN 'PL/SQL EXECUTE'
                WHEN name IN ( 'CREATE TABLE', 'CREATE CLUSTER', 'CREATE INDEX', 'ALTER TABLE', 'ALTER CLUSTER',
                               'ALTER INDEX', 'DROP TABLE', 'DROP CLUSTER', 'DROP INDEX' ) THEN 'DDL/SEGMENT'
                WHEN name IN ( 'CREATE MATERIALIZED VIEW', 'CREATE MATERIALIZED VIEW LOG', 'CREATE MATERIALIZED ZONEMAP', 'ALTER MATERIALIZED VIEW',
                'ALTER MATERIALIZED VIEW LOG','ALTER MATERIALIZED ZONEMAP', 'DROP MATERIALIZED VIEW', 'DROP MATERIALIZED VIEW LOG', 'DROP MATERIALIZED ZONEMAP' )
                               THEN 'DDL/MVIEW'
                WHEN name IN ( 'CREATE FUNCTION', 'CREATE PACKAGE', 'CREATE PACKAGE BODY', 'CREATE PROCEDURE', 'CREATE TRIGGER',
                               'CREATE TYPE', 'CREATE TYPE BODY', 'CREATE VIEW', 'CREATE SEQUENCE', 'ALTER FUNCTION',
                               'ALTER PACKAGE', 'ALTER PACKAGE BODY', 'ALTER PROCEDURE', 'ALTER TRIGGER', 'ALTER TYPE',
                               'ALTER TYPE BODY', 'ALTER VIEW', 'ALTER SEQUENCE', 'DROP FUNCTION', 'DROP PACKAGE',
                               'DROP PACKAGE BODY', 'DROP PROCEDURE', 'DROP TRIGGER', 'DROP TYPE', 'DROP TYPE BODY',
                               'DROP VIEW', 'DROP SEQUENCE' ) THEN 'DDL/PLSQL'
         -- WHEN 'GRANT OBJECT' THEN 'DCL'
                ELSE 'OTHER'
            END                                                AS command,
            name                                               command_name,
            translate(dbms_lob.substr(t.sql_text,2000) , CHR(10) || CHR(13), ' ')   sql_text,
            parsing_schema_name
        FROM
            dba_hist_sqlstat  g
            LEFT JOIN dba_hist_snapshot s ON ( g.snap_id = s.snap_id )
            INNER JOIN dba_hist_sqltext  t ON ( g.sql_id = t.sql_id )
            INNER JOIN audit_actions     aa ON ( command_type = aa.action )
        WHERE
            parsing_schema_name NOT IN ('ANONYMOUS','APEX_030200','APEX_PUBLIC_USER','APPQOSSYS','CTXSYS','DBSNMP','DIP',
                                       'EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA',
                                       'ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA',
                                       'SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL')
            AND g.snap_id = s.snap_id
            and g.dbid=t.dbid
   -- and s.begin_interval_time > sysdate - 7
    ) sub,
    (
        SELECT dbid,
            name
        FROM
            gv$database
    ) cont
WHERE
  cont.dbid=sub.dbid
GROUP BY
    dt,
    instance_number,
    cont.name,
    command,
    parsing_schema_name
ORDER BY
    dt
/

spool off
exit
