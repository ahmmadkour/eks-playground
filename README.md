# EKS Playground

A simple web application running on EKS cluster.

## Description

This is a hello world application running on EKS cluster, terraform and helm are used to create AWS resources and deploy the application.

ECR is used for the docker images and Karpenter for autoscaling.

## Getting Started

### Dependencies

You will need a running docker on your machine and the following cli tools:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* [docker](https://docs.docker.com/engine/install/)
* [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [helm](https://helm.sh/docs/intro/install/)

### Create AWS infrastructure

* Make sure you are using a test AWS account.
* Configure the AWS CLI with a user that has sufficient privileges to create needed AWS resources, you can use `aws configure`.
* Verify that the CLI can authenticate properly by running `aws sts get-caller-identity`.
* The terraform aws provider is configured to `us-east-1` region by default.
* Run the following terraform commands to createt the VPC, EKS, ECR and Karpenter:
```
cd terraform
terraform init
terraform plan
terraform apply
```

terraform will create `playground` VPC and EKS, and ECR repo `app`.

**Note:** you might get an error like `could not login to OCI registry "public.ecr.aws": open /etc/docker/certs.d/public.ecr.aws: permission denied`, you can fix it by changing the permission to `755` on both `/etc/docker` and `/etc/docker/certs.d` directories.

### Build docker image

* Run the following script to build the image and push it to ECR:
```
cd app
./image_build.sh
```

* The script will get current AWS account with `aws sts get-caller-identity --query Account --output text`.
* By default it uses `us-east-1` region but you can use a different region by passing it as an argument to the `image_buils.sh` script.

### Deploy the application

* Helm is used to deploy the application to the EKS cluster.
* Get access to the EKS cluster by running the following:
```
aws eks update-kubeconfig --region us-east-1 --name playground
```

* Install the helm chart with:
```
cd helm
helm install app ./app
```

### Test the application

* Run the following to be able to send traffic to your application from your laptop (You should have the same steps in the output from helm install command):
```
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=app,app.kubernetes.io/instance=app" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080
```

* Run the following and you should get back `Hello, World!`:
```
curl http://localhost:8080
```

* Watch the application logs with:
```
kubectl logs -f $POD_NAME
```

### Autoscaling

* karpenter is used for the autoscaling.
* Update the replica count to scale-up the app deployment:
```
kubectl scale deployment app --replicas 5
```

* You should see the new nodes named `karpenter.sh/provisioner-name/default` eventually come up in the AWS console.
* You can also run `kubectl get nodes` to see the new nodes in Kubernetes.
* You can watch Karpenter's controller logs with:
```
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
```


### Github Actions

A Github action is configured to run `golangci-lint` linting tool on the Golang app.
