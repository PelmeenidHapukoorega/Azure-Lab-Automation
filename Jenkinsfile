pipeline {
    agent any

    stages {
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