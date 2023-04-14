 -- Has to be executed on CDB
@spoolhead.sql
spool results/perf_cpu_waits.csv

select cont.name as pdb_name,
       ash.instance_number,
       ash.mtime,
       ash.event,
       ash.wait_class,
       ash.total_wait_time
from (SELECT instance_number,dbid,
        TO_CHAR(sample_time,'YYYY-MM-DD HH24') mtime,
        NVL(a.event, 'ON CPU') AS event,
        NVL(a.wait_class, 'ON CPU') AS wait_class,
        COUNT(*)*10 AS total_wait_time
      FROM   dba_hist_active_sess_history a
      GROUP BY instance_number,dbid,
            TO_CHAR(sample_time,'YYYY-MM-DD HH24'),
            a.event,
            a.wait_class
     ) ash,
     (select distinct name,dbid from v$database) cont
where cont.dbid=ash.DBID
ORDER BY pdb_name,mtime
/

spool off
exit

