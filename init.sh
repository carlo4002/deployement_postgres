#! /usr/bin/sh

# --- Script Body ---

assume_role(){

# Assume role
        echo "Assume role"

        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
        eval $(aws sts assume-role \
          --role-arn arn:aws:iam::154983253182:role/infra_secrets \
          --role-session-name test \
          --output text \
          --query 'Credentials.[join(`=`, [`export AWS_ACCESS_KEY_ID`, AccessKeyId]), join(`=`, [`export AWS_SECRET_ACCESS_KEY`, SecretAccessKey]), join(`=`, [`export AWS_SESSION_TOKEN`, SessionToken])]' | tr '\t' '\n')

        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

        echo "creds refreshed, check env"

}

assume_role

REPO_URL="github.com/carlo4002/deployement_postgres.git"
GITHUB_USERNAME="carlo4002"
PERSONAL_ACCESS_TOKEN=`aws secretsmanager get-secret-value --secret-id tokengithub --query SecretString --output text | jq -r '."tokengithub"'`
CLONE_URL="https://${GITHUB_USERNAME}:${PERSONAL_ACCESS_TOKEN}@${REPO_URL}"
TARGET_DIR="/usr/local/bin/"


echo "Starting Ansible installation script."
echo "Running as user: $(whoami)"

yum update -y
echo "Attempting to install ansible using dnf..."
dnf install -y ansible
echo "Attempting to install ansible-core using dnf..."
dnf install -y ansible-core
echo "Attempting to install git using dnf..."
dnf install -y git



rm -rf ${TARGET_DIR}/deployement_postgres

echo "Changing directory to ${TARGET_DIR}..."
cd "$TARGET_DIR"
echo "Attempting to clone repository into ${TARGET_DIR}..."

git clone "${CLONE_URL}"
