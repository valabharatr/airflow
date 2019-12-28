#!/usr/bin/env bash

# Get max ram available from quota
# https://github.com/fabric8io-images/s2i/blob/master/java/images/rhel/run-java.sh#L147
cpu_period_file="/sys/fs/cgroup/cpu/cpu.cfs_period_us"
cpu_quota_file="/sys/fs/cgroup/cpu/cpu.cfs_quota_us"
if [[ -r "${cpu_period_file}" ]]; then
  cpu_period="$(cat ${cpu_period_file})"
  if [[ -r "${cpu_quota_file}" ]]; then
    cpu_quota="$(cat ${cpu_quota_file})"
    # cfs_quota_us == -1 --> no restrictions
    if [[ ${cpu_quota:-0} -ne -1 ]]; then
      num_cores=$(python -c "from math import ceil; print(ceil(${cpu_quota}/${cpu_period}))")
    fi
  fi
fi

if [[ ! ${num_cores+x} ]]; then
  num_cores=$(grep -c ^processor /proc/cpuinfo)
fi

echo ${num_cores}