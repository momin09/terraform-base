variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "ecr_name" {
  description = "ECR 레포지토리 이름"
  type        = string
}
