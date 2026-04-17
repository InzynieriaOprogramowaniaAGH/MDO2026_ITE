pipeline {
    agent any

    environment {
        NAZWA_OBRAZU = "moje-app-express"
        WERSJA = "1.0.${BUILD_NUMBER}"
        KONTENER_TESTOWY = "testowa-instancja-app"
    }

    stages {
        stage('1. Pobieranie kodu') {
            steps {
                checkout scm
            }
        }

        stage('2. Budowanie i Testy (Builder)') {
            steps {
                echo "Buduję obraz Builder..."
                sh "docker build -t ${NAZWA_OBRAZU}:build -f Dockerfile.build ."
                
                echo "Uruchamiam testy..."
                sh "docker run --name tester-${BUILD_NUMBER} ${NAZWA_OBRAZU}:build npm test > wyniki_testow.txt"
            }
            post {
                always {
                    archiveArtifacts artifacts: 'wyniki_testow.txt', fingerprint: true
                    sh "docker rm tester-${BUILD_NUMBER} || true"
                }
            }
        }

        stage('3. Budowanie obrazu Runtime') {
            steps {
                echo "Tworzę lekki obraz produkcyjny..."
                sh "docker build -t ${NAZWA_OBRAZU}:${WERSJA} -f Dockerfile.runtime ."
            }
        }

        stage('4. Smoke Test (Deploy Integracyjny)') {
            steps {
                echo "Czyszczenie poprzednich kontenerów..."
                sh "docker stop ${KONTENER_TESTOWY} || true"
                sh "docker rm ${KONTENER_TESTOWY} || true"

                echo "Uruchamiam aplikację na porcie 3000..."
                sh "docker run -d --name ${KONTENER_TESTOWY} -p 3000:3000 ${NAZWA_OBRAZU}:${WERSJA}"

                echo "Weryfikacja (Smoke Test)..."
                sleep 5
                sh "docker run --rm --network host alpine sh -c 'apk add curl && curl -f http://localhost:3000'"
            }
            post {
                always {
                    sh "docker logs ${KONTENER_TESTOWY} > logi_aplikacji.txt"
                    archiveArtifacts artifacts: 'logi_aplikacji.txt'
                    sh "docker stop ${KONTENER_TESTOWY} || true"
                }
            }
        }

        stage('5. Publikacja Artefaktu') {
            steps {
                echo "Przygotowanie paczki redystrybucyjnej..."
                sh "tar -czvf app-v${WERSJA}.tar.gz package.json app.js"
                archiveArtifacts artifacts: "app-v${WERSJA}.tar.gz"
                
                echo "Pipeline zakończony sukcesem dla wersji ${WERSJA}"
            }
        }
    }
}
