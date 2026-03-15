pipeline {
    agent any

    // ── Environment variables ──────────────────────────────────────────────
    environment {
        APP_NAME        = 'myapp'
        DOCKER_REGISTRY = 'your-dockerhub-username'          // ← change this
        IMAGE_NAME      = "${DOCKER_REGISTRY}/${APP_NAME}"
        IMAGE_TAG       = "${GIT_COMMIT[0..6]}"               // short SHA tag
        DOCKER_CREDS    = credentials('dockerhub-credentials') // set in Jenkins
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    // ── Pipeline stages ────────────────────────────────────────────────────
    stages {

        stage('Checkout') {
            steps {
                echo "Branch: ${env.BRANCH_NAME}"
                echo "Commit: ${env.GIT_COMMIT}"
                checkout scm
            }
        }

        stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args  '-u root'
                    reuseNode true
                }
            }
            steps {
                sh 'npm ci'
            }
        }

        stage('Run Tests') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args  '-u root'
                    reuseNode true
                }
            }
            steps {
                sh 'npm run test:ci'
            }
            post {
                always {
                    // Publish test results and coverage in Jenkins UI
                    junit allowEmptyResults: true, testResults: '**/junit.xml'
                    publishHTML(target: [
                        allowMissing         : true,
                        alwaysLinkToLastBuild: true,
                        keepAll              : true,
                        reportDir            : 'coverage/lcov-report',
                        reportFiles          : 'index.html',
                        reportName           : 'Code Coverage'
                    ])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build \
                      --build-arg APP_VERSION=${IMAGE_TAG} \
                      -t ${IMAGE_NAME}:${IMAGE_TAG} \
                      -t ${IMAGE_NAME}:latest \
                      .
                """
            }
        }

        stage('Push to Registry') {
            // Only push on main/master branch
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                sh "echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin"
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy') {
            // Only deploy on main/master branch
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                sh """
                    export APP_VERSION=${IMAGE_TAG}
                    docker-compose pull
                    docker-compose up -d --remove-orphans
                """
            }
            post {
                success {
                    echo "Deployed ${IMAGE_NAME}:${IMAGE_TAG} successfully."
                }
            }
        }

    }

    // ── Post-pipeline actions ─────────────────────────────────────────────
    post {
        always {
            // Clean dangling images to save disk space
            sh 'docker image prune -f || true'
        }
        failure {
            echo "Pipeline FAILED. Check the logs above."
            // Add email/Slack notification here if needed
        }
        success {
            echo "Pipeline PASSED."
        }
    }
}
