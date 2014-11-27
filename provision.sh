#!/bin/sh

# Terminate script if anything fails
set +e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

APP_NAME=$1
ENVIRONMENT=$2

######################################################
#                                                    #
#                  S E T T I N G S                   #
#                                                    #
######################################################

# TODO change them according to your local paths
AWS_KEYS_FILE="${HOME}/.ec2/aws-${APP_NAME}.keys" # Amazon Web Services keys.
PRIVATE_KEY_FILE="${HOME}/.pems/${APP_NAME}.pem" # Used by ssh to connect without password.

# TODO change it if your are not using an ubuntu vm aka switch AIM image
REMOTE_USER="ubuntu"

#                                                    #
######################################################

display_usage() {
  echo "This script provisions vboxes for a specific project in vagrant as well on ec2."
  echo -e "\nUsage:\nprovision.sh <project> <development|testing|staging|production>\n"
}

if [  $# -le 0 ]
then
  display_usage
  exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ( $1 == "--help") ||  $1 == "-h" ]]
then
  display_usage
  exit 0
fi

if [ "${ENVIRONMENT}" = 'development' ]; then

  export APP_NAME="${APP_NAME}"
  echo "Provisioning ${APP_NAME} ${ENVIRONMENT} via Vagrant"

  # vagrantfile load APP_NAME as ENV variable
  vagrant up --no-provision && vagrant provision

elif [ "$ENVIRONMENT" = 'testing' ] || [ "$ENVIRONMENT" = 'staging' ] || [ "$ENVIRONMENT" = 'production' ]; then

  # remove last param
  shift

  echo "Checking ${PRIVATE_KEY_FILE} ..."
  if [ ! -f ${PRIVATE_KEY_FILE} ]; then
    echo "WARNING: ${PRIVATE_KEY_FILE} not found. Create or download it from AWS console"
    exit 1
  fi

  if [ ! -f ${AWS_KEYS_FILE} ]; then
    echo "WARNING: ${AWS_KEYS_FILE} not found. Create or download it from AWS console"
    exit 1
  fi

  echo "Export AWS Keys from ${AWS_KEYS_FILE}"
  . ${AWS_KEYS_FILE}

  echo "Bootstrap $ENVIRONMENT on EC2..."
  ansible-playbook -i ec2 aws-bootstrap.yml --extra-vars "environment=${ENVIRONMENT}" "ec2_access_key=${AWS_ACCESS_KEY_ID}" "ec2_secret_key=${AWS_SECRET_ACCESS_KEY}" $@

  echo "Provisioning $ENVIRONMENT on EC2"
  ansible-playbook -i plugins/inventory/ec2.py site.yml -u "${REMOTE_USER}" --private-key "${PRIVATE_KEY_FILE}" --extra-vars "app_name=${APP_NAME}" "environment=${ENVIRONMENT}" "ec2_access_key=${AWS_ACCESS_KEY_ID}" "ec2_secret_key=${AWS_SECRET_ACCESS_KEY}"  $@

else
  echo "Please specify a supported environment (development|testing|staging|production) "
fi
