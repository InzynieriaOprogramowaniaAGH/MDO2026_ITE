pipeline {
    agent any

    environment {
        BUILD_IMG  = "pipeline-build:${BUILD_NUMBER}"
        TEST_IMG   = "pipeline-test:${BUILD_NUMBER}"
    }

    stages {

        stage('Clone') {
            steps {
                git branch: 'SS419695',
                    url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git'
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${BUILD_IMG} -f SS419695/Dockerfile.build SS419695/"
            }
        }

        stage('Test') {
    steps {
        sh "docker run --rm ${BUILD_IMG} dotnet test app.test/app.test.csproj --logger 'console;verbosity=normal'"
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
                sh "docker cp pipeline-app:/app/app publish/"
                sh "zip -r app-${BUILD_NUMBER}.zip publish/"
                archiveArtifacts artifacts: "app-${BUILD_NUMBER}.zip", fingerprint: true
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