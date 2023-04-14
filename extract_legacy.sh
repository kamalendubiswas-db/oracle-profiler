#!/bin/bash 

# set debug
#set -x

prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input" 
    esac
  done
}

mkdir -p ./results
prompt_confirm "Previous extraction files in the 'results' folder will be removed ! Continue ? " || exit 0
rm -f ./results/*

read -p "Oracle Server hostname: " ora_host

read -p "Oracle Server port [1521]: " ora_port
ora_port=${ora_port:-1521}

read -p "Oracle Database Service name as registred in the Oracle listener: " ora_service

read -p "Username with privileges [SYSTEM]: " ora_username
ora_username=${ora_username:-SYSTEM}

read -p "Enter user password: " -s systemp

relative_script_cdb='scripts/legacy_11.2'
d=`date +%Y%m%d_%H%M`
outfile=oracleProfiler_${d}_${ora_service}.tar.gz
logfile=oracleProfiler_${d}_${ora_service}.log

for fic in `ls ${relative_script_cdb}/*.sql`
do
echo -e "\n Running sqlplus ${ora_username}/XXXXXX@${ora_host}:${ora_port}/${ora_service} @${fic}"
sqlplus -S -L ${ora_username}/${systemp}@${ora_host}:${ora_port}/${ora_service} @${fic}  | tee -a results/$logfile
rc=$?
if [ $rc -ne 0 ];
then
  echo -e "Error (rc=$rc) Occured during execution of the following command :\n sqlplus ${ora_username}/XXXXXX@${ora_host}:${ora_port}/${ora_service} @${fic}"
  exit 1
fi

done

pushd ./results > /dev/null 2>&1

tar -czf $outfile *.csv
rc=$?
popd > /dev/null 2>&1

if [ $rc -eq 0 ]
then
  echo -e "\n\n >>>>>>  Archive file results/$outfile is ready for processing"
else
  echo -e "\n\n >>>>>>  Error $rc occurs during archive creation of $outfile"
fi
