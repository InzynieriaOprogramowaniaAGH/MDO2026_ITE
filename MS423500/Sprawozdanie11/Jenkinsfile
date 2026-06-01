pipeline {
    agent any
    options {
        skipDefaultCheckout()
    }
    stages {
        stage('Clone') {
            steps {
                deleteDir()
                echo 'Pobieranie repozytorium...'
                sh 'git clone https://github.com/SaniolJR/ts_fork.git .'
            }
        }
        stage('Build') {
            steps {
                echo 'Budowanie obrazów z pliku Dockerfile.build...'
                sh "docker build -f Dockerfile.build --target tester -t nest-api:test -t nest-api:${BUILD_NUMBER} ."
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Uruchamianie testów...'
                sh 'docker run --rm nest-api:test'
            }
        }
        stage('Prepare Minikube') {
            steps {
                echo 'Pobieranie i uruchamianie Minikube lokalnie w środowisku Jenkinsa...'
                sh '''
                    if [ ! -f ./minikube ]; then
                        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                        chmod +x minikube-linux-amd64
                        mv minikube-linux-amd64 minikube
                    fi
                    
                    # Wymuszenie startu klastra z driverem docker (wsparcie np. dla kontenera Jenkins)
                    ./minikube start --force --driver=docker
                '''
            }
        }
        stage('Deploy Container') {
            steps {
                echo 'Budowanie obrazu wdrożeniowego v2...'
                sh "docker build -f Dockerfile.build --target runtime -t nest-api:v2 -t nest-api:${BUILD_NUMBER} ."

                echo 'Ładowanie obrazu do runtime Minikube...'
                sh './minikube image load nest-api:v2'

                echo 'Wdrażanie do Minikube...'
                sh './minikube kubectl -- apply -f nginx-deployment.yaml'
            }
        }
        stage('Smoke Test') {
            steps {
                echo 'Uruchamianie skryptu weryfikacyjnego (Timeout 60s)...'
                sh './verify_deploy_time.sh'
            }
        }
        stage('Publish') {
            steps {
                echo "Eksportowanie obrazu do pliku i archiwizacja w Jenkinsie..."
                // Zapisywanie obrazu do pliku .tar
                sh "docker save nest-api:v2 nest-api:${BUILD_NUMBER} -o nest-api-v${BUILD_NUMBER}.tar"
                // Archiwizacja pliku w Jenkinsie - to dodaje go do historii builda
                archiveArtifacts artifacts: "nest-api-v${BUILD_NUMBER}.tar", fingerprint: true
            }
        }
    }
    post {
        success { echo "✅ NARESZCIE SUKCES!" }
        failure { echo "❌ Coś jeszcze nie tak, ale jesteśmy blisko" }
    }
}
