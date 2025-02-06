pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'secure-api-cluster'
        DOCKER_IMAGE = 'dsourav155/secure-api:latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/dsourav155/secure-api-deployment.git'
            }
        }

        stage('Set up Docker Buildx') {
            steps {
                script {
                    // Create and use a new builder instance
                    sh 'docker buildx create --use'
                }
            }
        }

        stage('Build and Push Multi-Arch Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        // Log in to DockerHub
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        
                        // Build and push the multi-architecture image
                        sh '''
                            docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_IMAGE --push .
                        '''
                    }
                }
            }
        }

        stage('Configure AWS CLI') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                    sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                    sh 'aws configure set region $AWS_REGION'
                }
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh 'aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    kubectl apply -f kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/service.yaml
                '''
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD Pipeline executed successfully!'
        }
        failure {
            echo '❌ CI/CD Pipeline failed!'
        }
    }
}
