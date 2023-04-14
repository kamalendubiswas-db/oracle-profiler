-- Has to be executed on CDB 
@spoolhead.sql
spool results/config_pdb_objects.csv

SELECT cont.NAME as PDB_NAME,OWNER,OBJECT_TYPE,COUNT(*) as CNT
FROM DBA_OBJECTS o, (select name from v$database) cont
WHERE OWNER in (select username 
                from dba_users 
                where username not in ('ANONYMOUS','APEX_030200','APEX_PUBLIC_USER','APPQOSSYS','CTXSYS','DBSNMP','DIP',
                                       'EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA',
                                       'ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA',
                                       'SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL')
               )
GROUP BY NAME,OWNER,OBJECT_TYPE
ORDER BY 1,2
/


spool off
exit

