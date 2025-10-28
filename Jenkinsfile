pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        SONARQUBE_ENV = "sonarqube"
        DOCKER_IMAGE = "onsfidha/devops:latest"
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

        stage('Docker Login & Build Image') {
            steps {
                echo "🐳 Logging into Docker Hub and building image..."
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t $DOCKER_IMAGE .
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to Remote Kubernetes') {
            steps {
                echo "⚓ Deploying to remote Kubernetes cluster..."
                withCredentials([file(credentialsId: 'k8s-credentials', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_FILE
                        kubectl apply -f k8s/mysql-deployment.yaml
                        kubectl apply -f k8s/app-deployment.yaml
                        kubectl rollout status deployment/student-app
                    '''
                }
            }
        }

    }

    post {
        always {
            echo "🧹 Cleaning workspace..."
            cleanWs()
        }
        success {
            echo "✅ CI/CD pipeline completed successfully! App deployed to remote Kubernetes 🚀"
        }
        failure {
            echo "❌ CI/CD pipeline failed. Check logs for errors."
        }
    }
}
