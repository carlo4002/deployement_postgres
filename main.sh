#! /usr/bin/sh

# get tags
#exec &> /tmp/main.log

get_ips() {
  # Define the regions you want to query
  regions=("eu-west-1" "eu-west-3")

  # Initialize an empty array to hold all found IPs
  all_ips=()

  # Loop through each region
  for region in "${regions[@]}"; do
  # Run the describe-instances command for the current region
  # and capture the IPs
    ips_in_region=$(aws ec2 describe-instances \
      --region "$region" \
      --filters "Name=tag:Application,Values=postgres" \
              "Name=instance-state-name,Values=running" \
      --query 'Reservations[].Instances[].PrivateIpAddress' \
      --output text)

  # If IPs were found, add them to the all_ips array
    if [ -n "$ips_in_region" ]; then
      # The output text might have newlines, so we use readarray to handle them
      readarray -t current_region_ips <<< "$ips_in_region"
      all_ips+=("${current_region_ips[@]}")
    fi
  done

  # Echo all collected IPs on a single line, separated by spaces
  echo "${all_ips[@]}"
}

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

echo "getiing tags"
name=`aws ec2 describe-instances \
    --instance-ids ${INSTANCE_ID} \
    --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" \
    --output text`
echo "getting region"
instance_az=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' \
  --output text)
if [ -z "$instance_az" ]; then
  echo "Error: Instance ID '$instance_id' not found or no Availability Zone available."
  exit 1
fi

aws_region=$(echo "$instance_az" | awk '{print substr($1, 1, length($1)-1)}')

echo "getting region: $aws_region"

echo "getting ips"
ips=$(get_ips)

array=($(echo "$input" | tr -d '.' | tr -s ' '))

# Create an Ansible inventory file with the instance name and region
inventory_file="inventory.yml"

# Create the inventory file using a here-document
cat <<EOF > "${inventory_file}"
all:
  hosts:
    localhost:
      ansible_connection: local
      node_name: ${name}
      aws_region: ${aws_region}
      ips:
        - ${ips_array}
EOF


echo "Inventory file created: ${inventory_file}"
