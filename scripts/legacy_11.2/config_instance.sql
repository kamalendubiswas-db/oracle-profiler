-- Has to be executed on CDB
@spoolhead.sql
spool results/config_instance.csv
select inst_id,instance_name,version,'LEGACY - Version < 11.2' as database_type from gv$instance
/
spool off
exit

