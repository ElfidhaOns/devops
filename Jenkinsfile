pipeline {
    agent any

    stages {

        stage('Clone repository') {
            steps {
                echo "📥 Cloning Git repository..."
                git branch: 'main', url: 'https://github.com/ElfidhaOns/devops.git'
            }
        }

        stage('Deploy to Kubernetes (Minikube)') {
            steps {
                echo "⚓ Deploying to Kubernetes using local Minikube..."
                withEnv(["KUBECONFIG=/home/noussa/.minikube/config"]) {
                    sh '''
                        kubectl apply -f k8s/mysql-deployment.yaml
                        kubectl apply -f k8s/app-deployment.yaml
                        kubectl rollout status deployment/student-app
                    '''
                }
            }
        }

    }

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Deployment failed. Check logs."
        }
    }
}
