AWS Deployer Docker Image
=================================
This repository contains Docker image for running AWS cli commands that assumes a IAM role baked into one cli command. They can be useful for deploying AWS CloudFormation templates in e.g. a build server where the build server need to assume some other role to deploy.

For usage details go (here)[aws-deployer]

Extensions
=========
There are extensions avaliable for the base image that extends the functionality. See the (master readme)[../README.md]
 


#### Displaying help.
```sh
> docker run -it scaniadevtools/aws-deployer --help
  assume [-h|--help] [-v|--version] -a|--account <aws account number> [-r|--role <IAM role>] [-p|--profile <aws cli profile name>] []

  Assumes a role in the specified AWS account and creates temporary credentials in the named profile.
    -h|--help      prints this help
    -v|--version   prints the current version of this script
    -a|--account   the AWS account number to deploy to. (mandatory)
    -r|--role      the IAM role to assume
    -p|--profile   the name of the resulting aws cli profile to use
```

#### Displaying script version.

```sh
> docker run -it scaniadevtools/aws-deployer --version
  assume version 1.0.0
```

#### Assuming an AWS role. (Main use case)


In this example the command:

``assume --account 123456789012 --profile assumed-profile``

is used in a Gitlab ``.gitlab-ci.yml`` file for CI/CD. The Gitlab project contains an AWS CloudFormation template named ``cloudformation-template.yml`` that is validated in the AWS account *123456789012* by assuming the ``arn:aws:iam::123456789012:role/DeployRole`` role that exist in the specified AWS account and have ``cloudformation:ValidateTemplate`` permissions. The temporary credentials resulting from the assume command are stored in an AWS profile named ``assumed-profile``.

**.gitlab-ci.yml:**
```yml
image: scaniadevtools/docker-aws-deployer

stages:
  - validate-template 

validate-template-in-account-123456789012: 
  stage: validate-template

  before_script:
    - assume --account 123456789012 --profile assumed-profile
  script:
    - aws cloudformation validate-template --template-body file://cloudformation-template.yml --region eu-west-1 --profile assumed-profile
```
The account number (*123456789012* in this example) can be located in the AWS console when logged into the account by selecting   *"Support"->"Support Center"* in the menu.  


### Start a bash session inside the container.
Starting a bash session in the container can be useful for debugging purposes.

```sh
   > docker run -it scaniadevtools/aws-deployer bash
   bash-4.3#
```
## Links
[Docker image on Dockerhub](https://hub.docker.com/r/scaniadevtools/aws-deployer/)

__Happy Hacking__

*Scania Devtools Team*

## Want to contribute?
Go to the [CONTRIBUTING](../CONTRIBUTING.md) page.
