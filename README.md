# Site to Site VPN with Unifi 

## 構成図

<img src="./96.png">

## 準備

### Installation

* aws cli
* terraform

### tfstate 用の S3 を作成

```bash
YOUR_NAME="toge510" <- ここを更新

CURRENT_TIME=$(date +"%Y%m%d%H%M%S")
BUCKET_NAME="tfstate-${YOUR_NAME}-${CURRENT_TIME}"
echo "$BUCKET_NAME"

aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1
```

### main.tf を変更

`./terraform/main.tf`の 3 行目を変更

```bash
terraform {
  backend "s3" {
    bucket  = "tfstate-toge510-20250721182240" <- ここを更新
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
```

### git clone 

```bash
git clone https://github.com/toge510/aws_ans_practice.git
cd aws_ens_practice
```

### terraform 適用

```bash
cd ./terraform
terraform apply
-> yes
```