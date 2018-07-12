#!/bin/bash

VERSION=$(cat VERSION)

ROLE_NAME=DeployRole
PROFILE_NAME=deploy-profile

while test $# -gt 0
do
case $1 in

# Normal option processing
    -h | --help)
    echo "Usage:" >&2
    echo "assume [-h|--help] [-v|--version] -a|--account <aws account number> [-r|--role <IAM role>] [-p|--profile <aws cli profile name>] []" >&2
    echo "" >&2
    echo " Assumes a role in the specified AWS account and creates temporary credentials in the named profile." >&2
    echo "   -h|--help      prints this help" >&2
    echo "   -v|--version   prints the current version of this script" >&2
    echo "   -a|--account   the AWS account number to deploy to. (mandatory)" >&2
    echo "   -r|--role      the IAM role to assume (defaults to DeployRole)" >&2
    echo "   -p|--profile   the name of the resulting aws cli profile to use (defaults to deploy-profile)" >&2
    echo "" >&2
    exit 0
    ;;
    -v | --version)
    echo "assume version $VERSION" >&2
    exit 0
    ;;
    -a | --account)
    AWS_ACCOUNT_NO=$2
    shift
    ;;
    -r | --role)
    ROLE_NAME=$2
    shift
    ;;
    -p | --profile)
    PROFILE_NAME=$2
    shift
    ;;
# ...

# Special cases
    --)
    break
    ;;
    --*)
    echo "Invalid option: $1" >&2
    # error unknown (long) option $1
    ;;
    -?)
    echo "Invalid option: $1" >&2
    # error unknown (short) option $1
    ;;

# FUN STUFF HERE:
# Split apart combined short options
    -*)
    split=$1
    shift
    set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
    continue
    ;;

# Done with options
    *)
    break
    ;;
esac

shift
done

if [ -z "$AWS_ACCOUNT_NO" ]; then
    echo "account must be specified"
    exit 1
fi

AWS_CREDS=$(aws sts assume-role --role-arn arn:aws:iam::${AWS_ACCOUNT_NO}:role/${ROLE_NAME} --role-session-name AssumeSession --output json)
aws configure set aws_access_key_id $(echo "$AWS_CREDS" | jq '.Credentials.AccessKeyId?' -r) --profile ${PROFILE_NAME}
aws configure set aws_secret_access_key $(echo "$AWS_CREDS" | jq '.Credentials.SecretAccessKey?' -r) --profile ${PROFILE_NAME}
aws configure set aws_session_token $(echo "$AWS_CREDS" | jq '.Credentials.SessionToken?' -r) --profile ${PROFILE_NAME}
aws configure set region eu-west-1 --profile ${PROFILE_NAME}