## 1. About Oracle Profiler

The Profiler is a Migration Assessment Tool to explore and generate metrics out of an Oracle database . These metrics could be useful to understand workloads that are running in an Oracle environment and generate key insights into migration strategies.

## 2. Overview
The profiler consists of a main shell script, the extract script. This one will run consecutively a set of SQL scripts on the target database to extract valuable information (configuration and performance). These information will help Databricks' teams to size the Databricks environment.

Please note these scripts access only system tables and views and  **don't access business schemas**.

Before triggering the profiler, you have to verify that :
* Statistics on dictionary and fixed objects are up to date
* Customer is licenced on Enterprise Ed. **and** Diagnostics Pack
* All the scripts have to be executed on CDB:

#### Profiler Script Configutation
When launching the script 
`
./extract.sh
` or `extract_legacy.sh`, you'll be prompted to provide following information :
* Oracle Server hostname (on SCAN name if a RAC database is targeted)
* Oracle Server port [Default to 1521]
* Oracle Service name for the CDB\$ROOT container database (multitenant/single tenant) or the target database (non multitenant architecture) 
* SYSTEM or powered username password for CDB\$ROOT database (multitenant/single tenant) or the target database (non multitenant architecture) 

#### Information and Metrics Extracted
* **Appliance/Database configuration** : #CPU, #Cores, #Sockets, #Instances, #PDB.... (config_db_features.sql)
* **Instances configuration** (config_Instance.sql)
* **Containers configuration** (config_containers.sql)
* **PDBs configuration** (config_pdb_objects.sql)
* **Partitioning information** per PDB (config_pdb_partitions.sql)
* **Memory configuration** per PDB : shared, cached, java, ..... (config_memory_evol.sql)
* **Storage configuration** per PDB (config_storage.sql)
* **CPU waits** per PDB (perf_cpu_waits.sql)
* **Foreground Session evolution** (perf_fgd_session_evol.sql)
* **CPU Usage** per PDB (perf_hm.sql)
* **Workload Types** : PL/SQL, BI, ...  (perf_sqltext.sql) 


## 3. Supported Oracle versions

Due to Oracle kernel evolution, we tried to minimize the number of scripts and extractor script.

When a tuple "Version", "Multitenancy Archicture", "RAC / Single Instance" has been tested, I was done on Linux ( **No test have been done on AIX, Solaris, nor HP-UX** )

We currently have two different tracks:
* The legacy track. This track concerns Oracle version 11.2 and 12.1 (There's no compatible version for 10g and below)
Scripts have been tested on the following versions:

| Oracle Version  | MultiTenant/Legacy  | RAC  |Tested   |
|---|---|---|---|
| 11.2.0.4  | Legacy  | Y  | Should work  |
| 11.2.0.4 | Legacy  | N  | Done  |
| 12.1.0.2  | Legacy  | Y  | Should work  |
| 12.1.0.2  | Legacy  | N  | Done  |
| 12.1.0.2  | MT  | Y  | Should work  |
| 12.1.0.2  | MT  | N  | Done  |


* The main track. This track concerns Oracle versions (12.2, 19c and 21c)
Scripts tested on Oracle 19c (19.3) on linux - multitenant environment - No RAC

| Oracle Version  | MultiTenant/Legacy  | RAC  |Tested   |
|---|---|---|---|
| 12.2  | MT  | Y  | Done  |
| 12.2  | MT  | N  | Done  |
| 12.2  | Legacy  | Y  | Done  |
| 12.2  | Legacy  | N  | Done  |
| 19c  | MT  | Y  | Done  |
| 19c  | MT  | N  | Done  |
| 19c  | Legacy  | Y  | Done  |
| 19c  | Legacy  | N  | Done  |
| 21c  | MT  | Y  | Done  |
| 21c  | MT  | N  | Done  |

Note: Starting from 21c, legacy architecture is no more supported (Multitenant/single Tenant architecture is mandatory)

## 4. FAQ
* **Does the profiler extract any sensitive data ?**

The profiler extract only configuration and performance data. It does not access any of the company data. All queries are run with SYSTEM user.

* **Does running the profiler has any impact on the Database performance ?**

The profiler accesses only metadata tables and extracts small set of data

* **How much storage is needed to run the profiler?**

The profiler is only using some KBytes on the client for storing scripts and the profiler's content. 
Results of each profiler run is stored in the *results* folder and will use, depending on the target database, up to MBytes.




