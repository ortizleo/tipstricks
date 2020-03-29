################### QUERY SQL
select A.tablespace_name AS TABLESPACE,
TO_CHAR((SUM(C.BLOCKS)*100*COUNT(B.FILE_ID)/(SUM(B.BLOCKS)*COUNT(DISTINCT B.FILE_ID)))/COUNT(DISTINCT B.FILE_ID),'999.99') as PCTFR,
MAX(A.status) as STATUS
from dba_tablespaces A,
DBA_DATA_FILES B,
DBA_FREE_SPACE C
WHERE A.TABLESPACE_NAME=B.TABLESPACE_NAME
AND A.TABLESPACE_NAME=C.TABLESPACE_NAME
AND A.status ='ONLINE'
GROUP BY A.TABLESPACE_NAME
UNION
SELECT A.tablespace_name AS TABLESPACE,
TO_CHAR((FREE_SPACE/TABLESPACE_SIZE)*100, '999.99') as PCTFR,
'ONLINE' AS STATUS
FROM
dba_temp_free_space A;
exit

################## table.discovery.sh
#!/bin/sh

TEXT="{\""data\"":["
for checktable in $(cat /tmp/discovery.tablespace.txt | grep ONLINE | awk '{print$1}'); do
        TEXT="$TEXT{"\""{#TABLESPACE}"\"":"\""$checktable"\""}"
done
        TEXT="$TEXT]}"
        echo $TEXT | sed 's/}{/},{/g'

################## table.verify.space.sh
#!/bin/sh

TABLESPACE=$1

cat /tmp/discovery.tablespace.txt | awk '{ print $1 " " $2 }' | grep -e "^$TABLESPACE " | awk '{ print $2 }'


################## CRONTAB
***** * * * *      /etc/zabbix/scripts/oracletable.discovery.sh USER_ORACLE  > /tmp/discovery.tablespace.txt

