# Crossplane Secure Storage

## Motivation

Crossplane allows SREs and DevSecOps enthusiasts to dynamically provision cloud infrastructure from within their Kubernetes cluster. We need to securely provision RDS databases and S3 buckets.

## Prerequisites

1. AWS account and an AWS access token
2. Kubernetes cluster (see [https://kind.sigs.k8s.io/](KinD), [k3d.io](k3d), etc) running in AWS that will have access to our private RDS

## Setup

1. Deploy crossplane
    ```
    kubectl create namespace crossplane-system
    helm repo add crossplane-stable https://charts.crossplane.io/stable
    helm repo update
    helm install crossplane --namespace crossplane-system crossplane-stable/crossplane
    ```

2. Install the crossplane CLI
    ```
    curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
    ```

3. Add a secret with your AWS credentials
    1. Create a file named creds.conf populated with your access key and secret access key
        ```
        AWS_PROFILE=default && echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)" > creds.conf
        ```

    2. (alternate) hand-jam the creds.conf file
        ```
        [default]
        aws_access_key_id = [ACCESS KEY]
        aws_secret_access_key = [SECRET ACCESS KEY]
        ```

    3. Create the secret
        ```
        kubectl create secret generic aws-creds -n crossplane-system --from-file=creds=./creds.conf
        ```

4. 

## Terraform Assist

This section outlines the resources that will be built in AWS if you run the Terraform.
* VPC (internal CIDR 10.0.0.0/16)
* Internet Gateway
* Subnets
    * Public (internal CIDR 10.0.0.0/24)
    * Private (internal CIDR 10.0.1.0/24)
* Route Tables
    * Public route table for the public subnet, also set as VPC's default route table
    * Private route table for the private subnet
* Security Groups
    * Default security group with no ingress or egress specified, also set as VPC's default security group
    * Bastion security group for the bastion instance
        * Ingress from the internet over port 22 (0.0.0.0/0)
        * Egress anywhere (0.0.0.0/0)
    * K8s security group for the instance that will host Kubernetes
        * Ingress from the bastion over port 22 (10.0.0.0/24)
        * Egress anywhere (0.0.0.0/0)
* SSH keys
    * Bastion key for SSHing to the bastion
    * K8s key for SSHing to the instance that will host Kubernetes
* EC2 Instances
    * Bastion instance in the public subnet with a public IP adddress
    * K8s instance in the private subnet with a private IP address

1. Verify aws cli creds are functional
    ```
    aws s3 ls
    ```

2. Apply the Terraform to build the infrastructure
    ```
    cd assist/
    terraform apply
    ```

3. Extract the private keys that were generated
    ```
    terraform show -json | jq
    ```

4. Save the bastion key to something like `~/.ssh/cpss` and set file permissions
    ```
    chmod 0400 ~/.ssh/cpss
    ```

5. SSH to the Bastion
    ```
    ssh -i ~/.ssh/cpss ec2-user@[BASTION PUBLIC IP]
    ```

6. Save the k8s key onto the bastion to something like `~/.ssh/k8s` and set the file permissions
    ```
    chmod 0400 ~/.ssh/k8s
    ```

7. Install some stuff
    ```
    # Docker
    sudo yum update
    sudo yum install docker
    sudo usermod -a -G docker ec2-user
    newgrp docker
    sudo systemctl enable docker
    sudo systemctl start docker

    # kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x get_helm.sh 
    ./get_helm.sh 
    rm get_helm.sh

    # k3d
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    ```