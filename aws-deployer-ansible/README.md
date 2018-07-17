AWS Deployer Docker - Docker Image
=================================
This repository contains an extension of the aws-deployer docker image that adds possiblity to run ansible, ansible-lint and ansible-playbook


How to use
==========
Same as [``aws-deployer``](../aws-deployer) image.
Example .gitlab-ci.yml:

```yaml
stages:
  - check
  - deploy

check_playbooks:
  variables:
    GIT_SUBMODULE_STRATEGY: recursive
  only:
    - my-branch                                         # We will run the CD only when something is going to change in branch.
  image: scaniadevtools/aws-deployer-ansible
  stage: check
  script:
    - ansible-lint ansible-deploy.yaml                  # Lint the playbook

deploy-test-clad-dev:
  only:
    - my-branch                                         # We will run the CD only when something is going to change in branch.
  stage: deploy
  image: scaniadevtools/aws-deployer-ansible
  before_script:
    - mkdir -p ~/.ssh
    - export  EC2_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq  --raw-output '.region')
    - export AWS_ACCOUNT=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq  --raw-output '.accountId')
    - assume --account ${AWS_ACCOUNT} --role DeployRole --profile default   # Assume role in same account as GitLab runner
    - aws --region ${EC2_REGION} ssm get-parameter --name gitlab-2942-sshkey --with-decryption | jq --raw-output '.Parameter.Value' > ~/.ssh/id_rsa # Use private SSH key from SSM (destroyed together with container)
    - export AWS_PROFILE=default                                            # Make Ansible understand what boto profile to use
    - echo 'Host *' >> ~/.ssh/config                                        # Configure SSH
    - echo '  IdentityFile ~/.ssh/id_rsa' >> ~/.ssh/config                  # Use downloaded privkey
    - chmod -R 0600 ~/.ssh                                                  # Set file perms on ssh files
    - export ANSIBLE_HOST_KEY_CHECKING=no                                   # Disable host key authenticity checks
  script:
    - ansible-playbook --user=centos -c paramiko -e "CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME}" ansible-deploy.yaml
```

__Happy Hacking__

*Scania DC Extension Team*

## Want to contribute?
Go to the [CONTRIBUTING](../CONTRIBUTING.md) page.
