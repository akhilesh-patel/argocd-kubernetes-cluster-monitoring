pipeline {
    agent any

    tools {
        nodejs "Node 18"
    }

    environment {
        SONARQUBE_URL = 'http://192.168.29.237:30093/'
        DOCKER_IMAGE = "akhileshpatel123/react-app"
        REACT_APP_REPO = "https://github.com/akhilesh-patel/react-app.git"
        REACT_APP_BRANCH = "main"
        ARGOCD_REPO = "https://github.com/akhilesh-patel/argocd-kubernetes-cluster-monitoring.git"
        ARGOCD_BRANCH = "main"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${REACT_APP_BRANCH}",
                    credentialsId: 'github',
                    url: "${REACT_APP_REPO}"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube Scanner') {
                    withEnv(["PATH+SONAR_SCANNER=${tool 'SonarQube Scanner'}/bin"]) {
                        withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_AUTH_TOKEN')]) {
                            sh '''
                            echo "🔍 Node version:"
                            node -v

                            sonar-scanner \
                              -Dsonar.projectKey=react-app \
                              -Dsonar.sources=. \
                              -Dsonar.host.url=$SONARQUBE_URL \
                              -Dsonar.login=$SONAR_AUTH_TOKEN
                            '''
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "❌ Quality Gate failed: ${qualityGate.status}"
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def IMAGE_TAG = "v" + sh(script: "date +%s", returnStdout: true).trim()
                    env.IMAGE_TAG = IMAGE_TAG

                    sh """
                    docker build -t $DOCKER_IMAGE:$IMAGE_TAG .
                    """
                }
            }
        }

        stage('Trivy Vulnerability Scan') {
            steps {
                script {
                    sh """
                    echo "🔎 Running Trivy scan..."
                    trivy image --severity HIGH,CRITICAL --format table --output trivy-report.txt $DOCKER_IMAGE:$IMAGE_TAG || true
                    """
                }
                archiveArtifacts artifacts: 'trivy-report.txt', onlyIfSuccessful: true
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        sh """
                        echo $DOCKERHUB_PASSWORD | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                        docker push $DOCKER_IMAGE:$IMAGE_TAG
                        echo "✅ Successfully pushed: $DOCKER_IMAGE:$IMAGE_TAG"
                        """
                    }
                }
            }
        }

        stage('Update ArgoCD Repository') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh """
                        rm -rf argocd-repo
                        git clone -b ${ARGOCD_BRANCH} https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/akhilesh-patel/argocd-kubernetes-cluster-monitoring.git argocd-repo
                        cd argocd-repo

                       sed -i 's|image: akhileshpatel123/react-app:.*|image: akhileshpatel123/react-app:'"$IMAGE_TAG"'|' app/react-app-deploy.yml
                       sed -i 's|image: akhileshpatel123/react-app:.*|image: akhileshpatel123/react-app:'"$IMAGE_TAG"'|' app/react-app-service.yml


                        git config user.email "jenkins@ci.com"
                        git config user.name "Jenkins CI"
                        git add app/react-app-deploy.yml
                        git add app/react-app-service.yml
                        
                        git commit -m "🚀 Deploy new React image: $IMAGE_TAG"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/akhilesh-patel/argocd-kubernetes-cluster-monitoring.git HEAD:${ARGOCD_BRANCH}
                        """
                    }
                }
            }
        }
    }
}

