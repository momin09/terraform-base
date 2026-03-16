pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          containers:
          - name: terraform
            image: hashicorp/terraform:1.7
            command: ["/bin/sh", "-c", "cat"]
            tty: true
          - name: jnlp
            image: jenkins/inbound-agent:latest
      '''
    }
  }

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    AWS_DEFAULT_REGION    = "ap-northeast-2"
  }

  parameters {
    string(
      name: 'ECR_NAME',
      defaultValue: '',
      description: 'ECR 레포지토리 이름'
    )
    choice(
      name: 'ACTION',
      choices: ['plan', 'apply', 'destroy'],
      description: 'Terraform 액션'
    )
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        container('terraform') {
          sh 'terraform init -input=false'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        container('terraform') {
          sh """
            terraform plan \
              -var="ecr_name=${params.ECR_NAME}" \
              -input=false
          """
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        input message: "Apply를 실행합니까?", ok: "Apply"
        container('terraform') {
          sh """
            terraform apply \
              -var="ecr_name=${params.ECR_NAME}" \
              -auto-approve \
              -input=false
          """
        }
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        input message: "Destroy를 실행합니까?", ok: "Destroy"
        container('terraform') {
          sh """
            terraform destroy \
              -var="ecr_name=${params.ECR_NAME}" \
              -auto-approve \
              -input=false
          """
        }
      }
    }
  }

  post {
    success { echo "SUCCESS: ${params.ACTION} / ${params.ECR_NAME}" }
    failure { echo "FAILURE: ${params.ACTION} / ${params.ECR_NAME}" }
  }
}
