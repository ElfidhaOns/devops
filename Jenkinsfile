pipeline {
    agent any

    tools {
        maven 'Maven' // Must match the Maven installation name in Jenkins
    }

    environment {
        SONARQUBE_ENV = "sonarqube" // Must match the SonarQube server name in Jenkins
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
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=devops-project \
                        -Dsonar.host.url=http://localhost:9000
                    '''
                }
            }
        }

        stage('Package Application') {
            steps {
                echo "📦 Packaging application (.jar)..."
                sh 'mvn package -DskipTests'
            }
        }

    }

    post {
        success {
            echo "✅ CI completed successfully! Artifact is in target/."
        }
        failure {
            echo "❌ CI failed. Check Jenkins logs for details."
        }
        always {
            cleanWs() // Clean workspace after each build
        }
    }
}
