pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        SONARQUBE_ENV = "sonarqube"
    }

    stages {

        stage('Clone repository') {
            steps {
                echo "📥 Cloning Git repository..."
                git branch: 'main', url: 'https://github.com/ElfidhaOns/devops.git'
            }
        }

        stage('Start MySQL') {
            steps {
                echo "🚀 Starting MySQL using Docker Compose..."
                sh 'docker-compose down -v --remove-orphans || true'
                sh 'docker-compose up -d mysql'
                sh 'docker ps'
            }
        }

        stage('Build & Unit Tests') {
            steps {
                echo "🏗️ Building project and running unit tests..."
                sh 'mvn clean test'
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                echo "🔍 Running SonarQube analysis..."
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=student-management \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Package Application') {
            steps {
                echo "📦 Packaging application (.jar)..."
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image for Spring Boot app..."
                sh 'docker build -t student-app:latest .'
            }
        }

        stage('Push Docker Image to Local Minikube') {
            steps {
                echo "📤 Transferring image to Minikube Docker..."
                sh '''
                    minikube start --driver=docker --disk-size=50g
                    eval $(minikube docker-env)
                    docker build -t student-app:latest .
                '''
            }
        }

        stage('Deploy to Kubernetes (Minikube)') {
            steps {
                echo "⚓ Deploying application to Kubernetes..."
                sh '''
                    kubectl apply -f k8s/mysql-deployment.yaml
                    kubectl apply -f k8s/app-deployment.yaml
                    kubectl rollout status deployment/student-app
                '''
            }
        }

    }

    post {
        success {
            echo "✅ CI/CD pipeline completed successfully! Spring Boot app is deployed to Kubernetes 🚀"
        }
        failure {
            echo "❌ CI/CD pipeline failed. Check logs for errors."
        }
        always {
            cleanWs()
        }
    }
}
