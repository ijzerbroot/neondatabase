#!/bin/bash
set -x

if [ $# -ne 2 ]
then
    echo "Syntax: $0 timeline timestamp"
    echo "Example: $0 814ce0bd2ae452e11575402e8296b64d 2024-08-21T14:00:00Z"
    exit 
fi

curl -G -H "Content-Type: application/json" -vv "http://localhost:1234/v1/tenant/99336152a31c64b41034e4e904629ce9/timeline/$1/get_lsn_by_timestamp?timestamp=$2"
