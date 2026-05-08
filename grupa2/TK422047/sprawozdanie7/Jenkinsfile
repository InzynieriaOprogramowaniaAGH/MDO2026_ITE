pipeline {
    agent any

    environment {
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        DOCKER_HUB_USER = "tkaminskiagh" 
    }

   stages {
        stage('0. Clean & Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('1. Build (BLDR)') {
            steps {
                sh "docker build -t hiredis-bldr:${IMAGE_TAG} -f Dockerfile.build ."
            }
        }

        stage('2. Test') {
            steps {
                script {
                    sh "docker run -d --name redis-server-${BUILD_NUMBER} redis:alpine"
                    
                    try {
                        sh "docker run --rm --network container:redis-server-${BUILD_NUMBER} hiredis-bldr:${IMAGE_TAG} make test"
                    } catch (Exception e) {
                        error "Błąd podczas testów: ${e.message}"
                    } finally {
                        sh "docker stop redis-server-${BUILD_NUMBER} || true"
                        sh "docker rm redis-server-${BUILD_NUMBER} || true"
                    }
                }
            }
        }

        stage('3. Prepare Artifact & Deploy Image') {
            steps {
                sh "docker create --name temp-${BUILD_NUMBER} hiredis-bldr:${IMAGE_TAG}"
                sh "docker cp temp-${BUILD_NUMBER}:/app/libhiredis.so ./libhiredis.so"
                sh "docker rm temp-${BUILD_NUMBER}"
                
                sh "docker build -t ${DOCKER_HUB_USER}/hiredis-final:${IMAGE_TAG} -f Dockerfile.deploy ."
                sh "tar -cvzf hiredis-v${BUILD_NUMBER}.tar.gz libhiredis.so"
            }
        }

        stage('4. Deploy (Sandbox)') {
    steps {
        sh "docker rm -f hiredis-sandbox || true"
        sh "docker run -d --name hiredis-sandbox ${DOCKER_HUB_USER}/hiredis-final:${IMAGE_TAG}"
      
        sh "docker ps -a | grep hiredis-sandbox"
    }
}

     stage('5. Publish') {
    steps {
        archiveArtifacts artifacts: "hiredis-v${BUILD_NUMBER}.tar.gz", fingerprint: true
    }
}
    }

    post {
        always {
            sh 'docker image prune -f'
            sh "echo 'Build #${BUILD_NUMBER} Status: ${currentBuild.result}' > build_log.txt"
            archiveArtifacts artifacts: 'build_log.txt'
        }
    }
}
