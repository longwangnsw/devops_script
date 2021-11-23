#!/bin/bash
set -euo pipefail

while IFS= read -rd '' var; do export "$var"; done </proc/1/environ

WEEKDAY=$(date +%u)
DATE=$(date +%F)
NOTEBOOK_DIR_LOC="/opt/zeppelin/notebook"
BKP_DIR="/metrics/${MARATHON_APP_LABEL_NAME}/Notebook_BKP"
BKP_LOC=${BKP_DIR}/${DATE}

# Exit if there is NO persisted location to keep the Notebook backup
if ! mountpoint "/metrics/${MARATHON_APP_LABEL_NAME}" > /dev/null 2>&1; then
  echo "Dir - /metrics/${MARATHON_APP_LABEL_NAME} is NOT persisted location. Need to have a persisted location. e.g. Ceph mount for backup. Exiting..." | logger -t notebook_cleaner
  exit 1
fi

# Do NOT run script on week day
[[ ${WEEKDAY} < 5 ]] && echo "Cannot run Notebook cleaner script on a Week day as this can affect running Zeppelin instance. Exitting..." | logger -t notebook_cleaner && exit 1

[ -d ${BKP_LOC} ] || mkdir -p ${BKP_LOC}

echo "${DATE}:Start notebook cleanup of older than 90 days." | logger -t notebook_cleaner
find ${NOTEBOOK_DIR_LOC} -type f -iname *.json -atime +90 >> ${BKP_LOC}/${DATE}_list_notebook

for i in $(cat ${BKP_LOC}/${DATE}_list_notebook | tr " " "\n")
do
   DIR_NOTEBOOK_JSON="$(dirname "${i}")"
   cp -pr ${DIR_NOTEBOOK_JSON} ${BKP_LOC}
   if [ "$?" = 0 ]; then
     if [[ "${DIR_NOTEBOOK_JSON}" != "/opt/zeppelin/notebook/" ]] && [[ "${DIR_NOTEBOOK_JSON}" == "/opt/zeppelin/notebook/"* ]]; then
       rm -r ${DIR_NOTEBOOK_JSON}
     fi
   fi
done

cp -p ${ZEPPELIN_CONF_DIR}/notebook-authorization.json ${BKP_LOC}
cd ${BKP_DIR}
tar -czf ${BKP_LOC}.tar.gz ${DATE}
if gzip -t ${BKP_LOC}.tar.gz &> /dev/null; then
   rm -rf ${DATE}
fi
echo -e "${DATE}:End notebook cleanup of older than 90 days.\nRe-deploying container." | logger -t notebook_cleaner
# Re-deploys instance for proper synchronization of Notebook permission
kill 1
