@spoolhead.sql
spool results/perf_fgd_session_evol.csv

select con.name,sh.instance_number,
       to_char(snap.snap_time,'yyyy-mm-dd AMHH:MI:SS') as snap_time,
       count(distinct sh.session_id) as foregd_session_cnt
from dba_hist_active_sess_history sh,
(select dbid,name from v$database) con,
(select snap_id,instance_number,dbid,begin_interval_time snap_time from dba_hist_snapshot) snap
where 1=1
and sh.snap_id=snap.snap_id
and sh.instance_number=snap.instance_number
and sh.dbid=snap.dbid
and sh.dbid=con.dbid
and sh.session_type='FOREGROUND'
group by con.name, sh.instance_number, snap.snap_time
order by 1,3,2
/

spool off
exit

