#!/bin/bash

source /opt/intel/sgxsdk/environment

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/intel/sgxsdk/sdk_libs:/opt/intel/sgxpsw/aesm/:/opt/intel/sgxsdk/sdk_libs:/opt/intel/sgxpsw

sed -i 's/localhost:8081/'"$PCCS_HOST"'/g' /etc/sgx_default_qcnl.conf

/opt/intel/sgxpsw/aesm/aesm_service &
pid=$!

trap "kill ${pid}" TERM INT
sleep 2
exec "$@"