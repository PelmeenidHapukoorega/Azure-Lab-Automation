pipeline {
    agent any

    environment {
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure_client_secret')
        ARM_TENANT_ID = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    }

    stages {
        stage('Debug Env'){
            steps {
                sh 'echo "ARM_CLIENT_ID length: ${#ARM_CLIENT_ID}"'
                sh 'echo "ARM_SUBSCRIPTION_ID length: ${#ARM_SUBSCRIPTION_ID}"'
                sh 'echo "ARM_TENANT_ID length: ${#ARM_TENANT_ID}"'
            }
        }
        stage('Terraform init') {
            steps {
                dir('ScenarioBased/LogistikaOÜ/terraform') {
                    sh 'terraform init'
                }
            }
        }
        stage('Terrafrom validate') {
            steps {
                dir('ScenarioBased/LogistikaOÜ/terraform') {
                    sh 'terraform validate'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                dir('ScenarioBased/LogistikaOÜ/terraform') {
                    sh 'terraform plan'
                }
            }
        }
    }
}