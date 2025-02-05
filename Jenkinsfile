pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS = credentials('github-credentials')  /
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')  
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id') 
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  
        AWS_REGION = 'us-east-1'  
        DOCKER_IMAGE = 'dsourav155/secure-api:latest'  
        EKS_CLUSTER_NAME = 'secure-api-cluster'  
    }

    stages {

        stage('Checkout Code') {
            steps {
                git credentialsId: 'github-credentials', url: 'https://github.com/dsourav155/secure-api-deployment.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Login to DockerHub') {
            steps {
                sh 'echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                sh 'docker push $DOCKER_IMAGE'
            }
        }

        stage('Configure AWS CLI') {
            steps {
                sh '''
                aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                aws configure set region $AWS_REGION
                '''
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh 'aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh 'kubectl apply -f k8s-deployment.yaml'
                sh 'kubectl apply -f k8s-service.yaml'
            }
        }

    }

    post {
        success {
            echo "✅ CI/CD Pipeline executed successfully!"
        }
        failure {
            echo "❌ CI/CD Pipeline failed!"
        }
    }
}
