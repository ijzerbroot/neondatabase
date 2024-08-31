#!/bin/bash

# tenants list
/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenants

# tenant id
tenant_id=$(/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenants | grep -v + | grep -v Placement | awk -F'|' '{ print $2 }' | sed 's/  *//g')

# tenant details
/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id}

# Current pageserver
attached=$(/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id} | grep -v + | grep -v Shard | awk -F'|' '{ print $3 }' | sed 's/  *//g')

# Secondary pageserver
secondary=$(/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id} | grep -v + | grep -v Shard | awk -F'|' '{ print $4 }' | sed 's/  *//g')

#

echo start migration
# migrate tenant to pageserver
/home/frank/src/neon/target/release/storcon_cli --api http://localhost:1234 tenant-shard-migrate --tenant-shard-id ${tenant_id} --node ${secondary}

#
echo migration done

/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id}
#docker exec -ti neon-compute-1 psql -U cloud_admin -p 55433 -d postgres -c 'alter system set 


echo migrating back
# tenant id
tenant_id=$(/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenants | grep -v + | grep -v Placement | awk -F'|' '{ print $2 }' | sed 's/  *//g')

# tenant details
/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id}

# Current pageserver
attached=$(/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id} | grep -v + | grep -v Shard | awk -F'|' '{ print $3 }' | sed 's/  *//g')

# Secondary pageserver
secondary=$(/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id} | grep -v + | grep -v Shard | awk -F'|' '{ print $4 }' | sed 's/  *//g')

#

echo start migration
# migrate tenant to pageserver
/home/frank/src/neon/target/release/storcon_cli --api http://localhost:1234 tenant-shard-migrate --tenant-shard-id ${tenant_id} --node ${secondary}

echo migration back done

/home/frank/src/neon/target/release/storcon_cli --api http://127.0.0.1:1234 tenant-describe --tenant-id ${tenant_id}
