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

        stage('Build & Unit Tests') {
            steps {
                echo "🏗️ Building project and running unit tests..."
                sh 'mvn clean'
                sh 'mvn test'
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
                sh 'docker build -t student-app .'
            }
        }

        stage('Run with MySQL (Docker Compose)') {
            steps {
                echo "🚀 Starting app and MySQL using docker-compose..."
                sh 'docker-compose down -v --remove-orphans || true' // stop previous containers if any
                sh 'docker-compose up -d --build'
                sh 'docker ps'
            }
        }

    }

    post {
        success {
            echo "✅ CI completed successfully! Application and MySQL are running in Docker."
        }
        failure {
            echo "❌ CI failed. Check Jenkins logs for details."
        }
        always {
            cleanWs()
        }
    }
}
