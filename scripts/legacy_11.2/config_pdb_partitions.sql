@spoolhead.sql
spool results/config_pdb_partitions.csv

SELECT cont.NAME as PDB_NAME,OWNER,OBJECT_TYPE,CNT
from
(
    select owner,'TABLE (NON PARTITIONED)' as OBJECT_TYPE,count(*) as cnt from dba_tables where partitioned='NO' group by owner
    union
    select owner,'TABLE (PARTITIONED)',count(*) as cnt from dba_tables where partitioned='YES' group by owner
    union
    select owner,'INDEX (NON PARTITIONED)',count(*) as cnt from dba_indexes where partitioned='NO' group by owner
    union
    select owner,'INDEX (PARTITIONED)',count(*) as cnt from dba_tables where partitioned='YES' group by owner
    union
    select owner,'LOBS (NON PARTITIONED)',count(*) as cnt from dba_lobs where partitioned='NO' group by owner
    union
    select owner,'LOBS (PARTITIONED)',count(*) as cnt from dba_lobs where partitioned='YES' group by owner
) u,
(select name from v$database) cont
WHERE OWNER in (select username from dba_users 
                WHERE username not in ('ANONYMOUS','APEX_030200','APEX_PUBLIC_USER','APPQOSSYS','CTXSYS','DBSNMP','DIP',
                                       'EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA',
                                       'ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA',
                                       'SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL')
                )                       
ORDER BY 1,2
/

spool off
exit

