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

        stage('Start MySQL for Tests') {
            steps {
                echo "🛢️ Starting MySQL container for tests..."
                sh '''
                    docker run -d --name mysql-test \
                        -e MYSQL_ROOT_PASSWORD=root \
                        -e MYSQL_DATABASE=studentdb \
                        -p 3306:3306 \
                        mysql:8
                    echo "Waiting 20s for MySQL to initialize..."
                    sleep 20
                '''
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

        stage('Start Minikube & Prepare Docker') {
            steps {
                echo "🚀 Starting Minikube (if not already running) and configuring Docker..."
                sh '''
                    if ! minikube status &>/dev/null; then
                        minikube start --driver=docker --cpus=2 --memory=8g --disk-size=50g
                    else
                        echo "Minikube already running"
                    fi
                    eval $(minikube docker-env)
                '''
            }
        }

        stage('Build Docker Image for Minikube') {
            steps {
                echo "🐳 Building Docker image for Spring Boot app in Minikube Docker..."
                sh 'docker build -t student-app:latest .'
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
        always {
            echo "🧹 Cleaning up MySQL test container..."
            sh 'docker stop mysql-test || true && docker rm mysql-test || true'
            cleanWs()
        }
        success {
            echo "✅ CI/CD pipeline completed successfully! Spring Boot app is deployed to Kubernetes 🚀"
        }
        failure {
            echo "❌ CI/CD pipeline failed. Check logs for errors."
        }
    }
}
