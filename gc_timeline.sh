#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Syntax: $0 timeline_id"
  exit 1
fi

timeline_id="$1"

PARAMS=(
     -X PUT
     -vv
     "http://localhost:9898/v1/tenant/99336152a31c64b41034e4e904629ce9/timeline/${timeline_id}/do_gc"
)
result=$(curl "${PARAMS[@]}")
echo $result 
