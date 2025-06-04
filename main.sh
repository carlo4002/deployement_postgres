#! /usr/bin/sh

# get tags
#exec &> /tmp/main.log

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

echo "getiing tags"
name=`aws ec2 describe-instances \
    --instance-ids ${INSTANCE_ID} \
    --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" \
    --output text`
inventory_file="inventory.in"

# Create the inventory file using a here-document
cat <<EOF > "${inventory_file}"
[localhost]
localhost ansible_connection=local

[localhost:vars]
name=${name}
EOF


