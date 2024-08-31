#!/bin/bash


PARAMS=(
     -sb
     -X GET
     -H "Content-Type: application/json"
     "http://localhost:1234/v1/tenant/99336152a31c64b41034e4e904629ce9/timeline/"
)
result=$(curl "${PARAMS[@]}")
echo $result | jq .
