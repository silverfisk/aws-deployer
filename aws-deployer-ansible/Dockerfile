FROM scaniadevtools/aws-deployer:latest
RUN apk update
RUN apk add zip jq python python2-dev py2-pip gcc linux-headers libffi-dev openssl-dev make musl-dev
RUN pip install --upgrade pip
RUN pip install --upgrade boto boto3 ansible
