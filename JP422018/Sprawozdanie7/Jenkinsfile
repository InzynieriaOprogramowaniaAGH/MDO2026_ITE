pipeline {
    agent any

    environment {
        IMAGE_NAME    = "kanye-counter"
        REGISTRY_USER = "jpadlo"
        REGISTRY_IMAGE = "${REGISTRY_USER}/${IMAGE_NAME}"
        VERSION       = "1.0.${BUILD_NUMBER}"
    }

    stages {
        stage('Clone') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh """
                    docker build \
                    --build-arg GIT_COMMIT=\$(git rev-parse --short HEAD) \
                    --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                    --build-arg BUILD_DATE=\$(date -u +%Y-%m-%dT%H:%M:%SZ) \
                    -t ${IMAGE_NAME}:${VERSION} \
                    -t ${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Test') {
            steps {
                script {
                    // Wykorzystujemy istniejącą fazę 'builder' z Dockerfile
                    sh "docker build --target builder -t ${IMAGE_NAME}-test ."
                    
                    // Uruchamiamy testy
                    sh "docker run --rm ${IMAGE_NAME}-test pnpm test"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "docker rm -f kanye-web-container || true"
                sh "docker run -d --name kanye-web-container -p 3000:3000 ${IMAGE_NAME}:${VERSION}"
            }
        }

        stage('Publish') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    sh "docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY_IMAGE}:${VERSION}"
                    sh "docker tag ${IMAGE_NAME}:latest ${REGISTRY_IMAGE}:latest"
                    sh "docker push ${REGISTRY_IMAGE}:${VERSION}"
                    sh "docker push ${REGISTRY_IMAGE}:latest"
                    echo "Opublikowano ${REGISTRY_IMAGE}:${VERSION} i :latest"
                }
            }
        }
    }

    post {
        always {
            script {
                sh "docker inspect ${IMAGE_NAME}:${VERSION} > docker-inspect-${VERSION}.json || true"
            }
            archiveArtifacts artifacts: "docker-inspect-${VERSION}.json", allowEmptyArchive: true
        }
    }
}