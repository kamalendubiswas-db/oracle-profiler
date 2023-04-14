@spoolhead.sql
spool results/config_memory_evolution.csv

select      param.instance_number,
            to_char(snap.snap_time,'yyyy-mm-dd AMHH:MI:SS') as snap_time,
            parameter_name,
            value
from dba_hist_parameter param,
(select snap_id,dbid,instance_number,begin_interval_time snap_time from dba_hist_snapshot) snap
where 1=1
and param.snap_id=snap.snap_id
and param.dbid=snap.dbid
and param.instance_number=snap.instance_number
and param.parameter_name in ('sga_target',
                             'pga_aggregate_target',
                             'db_cache_size',
                             'shared_pool_size',
                             'large_pool_size',
                             'java_pool_size',
                             'streams_pool_size',
                             'db_16k_cache_size',
                             'db_2k_cache_size',
                             'db_32k_cache_size',
                             'db_4k_cache_size',
                             'db_8k_cache_size',
                             'memory_target',
                             'memory_max_target')
order by 1,3,2
/

spool off
exit
