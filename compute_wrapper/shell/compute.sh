#!/bin/bash
set -eux

# Generate a random tenant or timeline ID
#
# Takes a variable name as argument. The result is stored in that variable.
generate_id() {
    local -n resvar=$1
    printf -v resvar '%08x%08x%08x%08x' $SRANDOM $SRANDOM $SRANDOM $SRANDOM
}

PG_VERSION=${PG_VERSION:-16}

SPEC_FILE_ORG=/var/db/postgres/specs/spec.json
SPEC_FILE=/tmp/spec.json

echo "Waiting pageserver become ready."
while ! nc -z storage_controller 1234; do
     sleep 1;
done
echo "Page server is ready."

echo "Create a tenant and timeline"
#generate_id tenant_id
tenant_id="99336152a31c64b41034e4e904629ce9"
PARAMS=(
     -X PUT
     -H "Content-Type: application/json"
     -d "{\"mode\": \"AttachedSingle\", \"generation\": 1, \"tenant_conf\": {\"pitr_interval\": \"20m\", \"compaction_target_size\": 536870912, \"page_cache_size\": 131072, \"image_creation_threshold\": 3, \"checkpoint_distance\": 268435456, \"gc_period\": \"5m\"}}"
     "http://storage_controller:1234/v1/tenant/${tenant_id}/location_config"
)
result=$(curl "${PARAMS[@]}")
echo $result | jq .

#generate_id timeline_id
timeline_id="814ce0bd2ae452e11575402e8296b64d"
#timeline_id="814ce0bd2ae452e11575402e829fffff"
PARAMS=(
     -sb
     -X POST
     -H "Content-Type: application/json"
     -d "{\"new_timeline_id\": \"${timeline_id}\", \"pg_version\": ${PG_VERSION}}"
     "http://storage_controller:1234/v1/tenant/${tenant_id}/timeline/"
)
result=$(curl "${PARAMS[@]}")
echo $result | jq .

echo "Overwrite tenant id and timeline id in spec file"
sed "s/TENANT_ID/${tenant_id}/" ${SPEC_FILE_ORG} > ${SPEC_FILE}
sed -i "s/TIMELINE_ID/${timeline_id}/" ${SPEC_FILE}

cat ${SPEC_FILE}

echo "Start compute node"
/usr/local/bin/compute_ctl --pgdata /var/db/postgres/compute \
     -C "postgresql://cloud_admin@localhost:55433/postgres"  \
     -b /usr/local/bin/postgres                              \
     -S ${SPEC_FILE}
