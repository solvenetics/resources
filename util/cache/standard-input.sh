if echo ${STANDARD_INPUT} | ${INIT} > ${OUT} 2> ${ERR}
then
    echo ${?} > ${STATUS}
else
    echo ${?} > ${STATUS}
fi &&
  chmod 0400 ${OUT} ${ERR} ${STATUS} &&
  touch ${FLAG}