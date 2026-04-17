pipeline {
    agent any

    environment {
        APP_VERSION = "5.2.1"
        IMAGE_BUILD = "express-build:${APP_VERSION}"
        IMAGE_TEST  = "express-test:${APP_VERSION}"
        IMAGE_PROD  = "express-prod:${APP_VERSION}"
    }

    stages {

        stage('Cleanup') {
            steps {
                sh 'docker stop express-app || true'
                sh 'docker rm   express-app || true'
                sh 'docker rmi  express-build:5.2.1 || true'
                sh 'docker rmi  express-test:5.2.1  || true'
                sh 'docker rmi  express-prod:5.2.1  || true'
                sh 'rm -rf artifacts test-results.txt'
                cleanWs()
                echo "Workspace wyczyszczony – swieze repo"
            }
        }

        stage('Build') {
            steps {
                checkout scm
                sh "docker build -f Dockerfile.build -t ${IMAGE_BUILD} ."
                sh "docker run --rm ${IMAGE_BUILD}"
            }
            post {
                success { echo "Obraz ${IMAGE_BUILD} zbudowany" }
            }
        }

        stage('Test') {
            steps {
                sh "docker build -f Dockerfile.test -t ${IMAGE_TEST} ."
                sh "docker run --rm ${IMAGE_TEST} | tee test-results.txt"
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test-results.txt',
                                     allowEmptyArchive: true
                }
                failure {
                    echo "TESTY NIEUDANE – sprawdz test-results.txt"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "docker build -f Dockerfile.production -t ${IMAGE_PROD} ."
                sh "docker run -d --name express-app -p 3000:3000 ${IMAGE_PROD}"
                sh "sleep 3"
                sh "curl -f http://localhost:3000 || exit 1"
                echo "Smoke test zaliczony"
            }
        }

        stage('Publish') {
            steps {
                sh "mkdir -p artifacts"
                sh "docker run --rm -v \$(pwd)/artifacts:/output ${IMAGE_BUILD} sh -c 'npm pack && cp *.tgz /output/'"
                sh "ls -lh artifacts/"
                archiveArtifacts artifacts: 'artifacts/*.tgz', fingerprint: true
                echo "Artefakt express-${APP_VERSION}.tgz opublikowany"
            }
        }
    }

    post {
        always {
            sh 'docker stop express-app || true'
            sh 'docker rm   express-app || true'
            echo "Kontenery tymczasowe usuniete"
        }
        success { echo "Pipeline OK – wersja ${APP_VERSION}" }
        failure { echo "Pipeline BLAD – sprawdz logi" }
    }
}
