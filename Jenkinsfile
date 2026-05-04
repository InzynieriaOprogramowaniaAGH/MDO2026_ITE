pipeline {
    agent any

    environment {
        BUILD_IMG  = "pipeline-build:${BUILD_NUMBER}"
        TEST_IMG   = "pipeline-test:${BUILD_NUMBER}"
    }

    stages {

        stage('Prepare') {
            steps {
                cleanWs()
                git branch: 'SS419695',
                    url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git'
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${BUILD_IMG} -f Dockerfile.build ."
            }
        }

        stage('Test') {
            steps {
                sh "docker build -t ${TEST_IMG} --build-arg BUILD_NUMBER=${BUILD_NUMBER} -f Dockerfile.test ."
            }
            post {
                always {
                    sh "docker rmi ${TEST_IMG} || true"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "docker stop pipeline-app || true"
                sh "docker rm pipeline-app || true"
                sh "docker run -d --name pipeline-app ${BUILD_IMG} tail -f /dev/null"
                sh "docker ps | grep pipeline-app"
            }
        }

        stage('Publish') {
        steps {
        sh "mkdir -p publish"
        sh "docker cp pipeline-app:/app/app/bin/Release/net8.0 publish/"
        sh "tar -czf app-${BUILD_NUMBER}.tar.gz publish/"
        archiveArtifacts artifacts: "app-${BUILD_NUMBER}.tar.gz", fingerprint: true
    }
}
    }

    post {
        always {
            sh "docker rmi ${BUILD_IMG} || true"
            sh "docker stop pipeline-app || true"
            sh "docker rm pipeline-app || true"
        }
        success {
            echo "Artefakt: app-${BUILD_NUMBER}.zip"
        }
        failure {
            echo "Pipeline FAILED - sprawdz logi"
        }
    }
}