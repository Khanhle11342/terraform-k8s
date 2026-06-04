# Terraform Minikube on AWS

Repo nay dung Terraform de tao mot EC2 Ubuntu tren AWS, cai Minikube tren EC2, deploy mot app HTTP nhe vao Kubernetes, va dua traffic public vao app bang AWS Application Load Balancer.

## Chay tu repo sach

Yeu cau truoc khi chay:

- Da cai Terraform.
- AWS credentials da duoc cau hinh san, vi du qua `aws configure` hoac bien moi truong `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.
- AWS account co default VPC trong region `ap-southeast-2`.

Lenh chay:

```bash
terraform init && terraform apply -auto-approve
```

Sau khi apply xong, Terraform in ra:

```text
app_url = "http://<alb-dns-name>"
```

Mo URL do tren browser de kiem tra app. Noi dung tra ve se la:

```text
Welcome to Khanh DevOps Lab
```

Don tai nguyen sau khi cham xong:

```bash
terraform destroy -auto-approve
```

## Kien truc

```text
User / Browser
  |
  | HTTP :80
  v
AWS Application Load Balancer
  |
  | forwards to target group :30080
  v
EC2 Ubuntu instance
  |
  | Minikube node, Docker driver
  v
Kubernetes NodePort Service :30080
  |
  | targetPort :5678
  v
hello Deployment
  |
  v
hashicorp/http-echo:1.0.0
```

Terraform flow:

```text
AWS provider
  -> default VPC/subnets
  -> security group
  -> generated AWS key pair
  -> EC2 instance
  -> ALB, listener, target group

TLS provider
  -> generate SSH private/public key
  -> public key is registered as AWS key pair

Null provider
  -> SSH provisioner into EC2
  -> copy install script
  -> install Docker, Minikube, kubectl
  -> copy Kubernetes manifests
  -> run kubectl apply
```

## Provider

Repo dung 3 provider:

- `hashicorp/aws`: tao va doc tai nguyen AWS.
- `hashicorp/tls`: tao SSH key pair de dung cho EC2.
- `hashicorp/null`: chay provisioning qua SSH sau khi EC2 duoc tao.

Cach wire provider:

```text
tls_private_key.ssh
  -> aws_key_pair.k8s
  -> aws_instance.k8s
  -> null_resource.install_minikube
  -> null_resource.deploy_app
```

`aws_instance.k8s` dung key pair tao tu `tls_private_key.ssh`. Hai `null_resource` dung private key do trong block `connection` de SSH vao EC2.

## Lua chon thiet ke

App duoc chon la `hashicorp/http-echo:1.0.0` vi nho, khong can build image rieng, va de chung minh traffic da vao dung pod Kubernetes.

Cluster dung Minikube thay vi EKS de giu bai tap nhe va chi can mot EC2 instance. Minikube chay voi Docker driver vi Docker cai don gian tren Ubuntu va phu hop cho single-node demo.

App duoc dua vao cum bang `kubectl apply` thong qua Terraform `null_resource`, khong cai truc tiep len EC2. EC2 chi dong vai tro host cho Minikube; workload that su nam trong Kubernetes.

Network dung default VPC/subnets de giam so luong tai nguyen phai quan ly. Voi bai demo, cach nay du de tao ALB public va EC2 target. Neu lam production, nen tao VPC rieng, subnet public/private rieng, security group tach rieng cho ALB va EC2.

## Cau truc thu muc

```text
.
|-- provider.tf
|-- variables.tf
|-- network.tf
|-- sg.tf
|-- keypair.tf
|-- ec2.tf
|-- k8s.tf
|-- deploy_app.tf
|-- alb.tf
|-- outputs.tf
|-- scripts/
|   `-- install_minikube.sh
`-- manifests/
    |-- deployment.yaml
    `-- service.yaml
```

Repo hien tai dung root module duy nhat, chua tach module con. Voi quy mo bai tap nho, cau truc flat giup doc nhanh va de cham. Khi mo rong, co the tach thanh `modules/network`, `modules/compute`, `modules/k8s-bootstrap`, va `modules/alb`.

## Bien

`variables.tf` hien co:

```hcl
variable "key_name" {
  default = "terraform-k8s"
}
```

Bien nay dat ten AWS key pair do Terraform tao. Private key khong can truyen tu ngoai vao nua; provider `tls` tu tao trong qua trinh apply.

## Bang chung

Sau khi chay apply, chup anh man hinh browser mo output `app_url`. Anh/clip do la bang chung URL ALB mo duoc app.

http://hello-alb-1212541323.ap-southeast-2.elb.amazonaws.com/

<img width="839" height="155" alt="image" src="https://github.com/user-attachments/assets/3dd56aad-bb04-41db-a740-5d06422a988e" />

