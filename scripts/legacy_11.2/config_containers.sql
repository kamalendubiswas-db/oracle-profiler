-- Has to be executed on CDB
@spoolhead.sql
spool results/config_containers.csv
select listagg(inst_id, ',') within group (order by name) as inst_ids,name,open_mode,0 as pdb_count from gv$database group by name,open_mode
/
spool off
exit

