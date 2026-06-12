1. Weryfikowanie punktów kontrolnych:

-  Przepis dostarczany z SCM, a nie wklejony w Jenkinsa lub sprawozdanie (co załatwia nam clone )

![alt text](img/image\.png)

- Pracuje na najnowszym (a nie cache'owanym kodzie)

![alt text](img/image\-1.png)

- Etap Build dysponuje repozytorium i plikami Dockerfile

![alt text](img/image\-2.png)

- Etap Build tworzy obraz buildowy (BLDR)

![alt text](img/image\-3.png)

- Przygotowanie artefaktu

![alt text](img/image\-10.png)

Etap Build kończy się w momencie pomyślnej kompilacji obrazu. Wydzielenie pakowania do osobnego etapu pozwala jasno odseparować proces tworzenia oprogramowania od procesu jego dystrybucji.

-  Etap Test przeprowadza testy

![alt text](img/image\-4.png)

- Etap Deploy przygotowuje obraz/artefakt pod wdrożenie

![alt text](img/image\-5.png)

- Etap Deploy przeprowadza wdrożenie (Sandbox)

![alt text](img/image\-6.png)

- Etap Publish wysyła obraz docelowy do Rejestru i dodaje artefakt do historii builda

![alt text](img/image\-7.png)

- Ponowne uruchomienie

![alt text](img/image\-8.png)

Sprawdzenie czy pipelin działą więcej niz jeden raz:

![alt text](img/image\-9.png)

- Konfiguracja pipeline (Jenkinsfile)

```groovy
pipeline {
    agent any

    stages {
        stage('0. Clean & Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('1. Build (BLDR)') {
            steps {
                echo 'Budowanie obrazu buildowego (BLDR)'
                sh 'docker build -t hiredis-bldr -f Dockerfile.build .'
            }
        }
        stage('2. Test') {
    steps {
        echo 'Uruchamianie bazy Redis i testów integracyjnych...'
        script {
            sh 'docker run -d --name redis-server redis:alpine'
            
            try {
                sh 'docker run --rm --network container:redis-server hiredis-bldr make test'
                echo 'Testy zakończone sukcesem!'
            } catch (Exception e) {
                echo 'Testy nie powiodły się!'
                error "Błąd podczas testów: ${e.message}"
            } finally {
                sh 'docker stop redis-server || true'
                sh 'docker rm redis-server || true'
            }
        }
    }
}
        stage('3. Prepare Artifact') {
            steps {
                echo 'Wyciąganie pliku binarnego z obrazu BLDR...'
                sh 'docker rm -f temp-container || true'
                sh 'docker create --name temp-container hiredis-bldr'
                sh 'docker cp temp-container:/app/libhiredis.so ./libhiredis.so'
                sh 'docker rm temp-container'
                
                sh 'tar -cvzf hiredis-paczka.tar.gz libhiredis.so'
            }
        }

        stage('4. Deploy (Sandbox Verification)') {
            steps {
                echo 'Wdrożenie i weryfikacja w środowisku sandboxowym...'
                sh 'docker run --rm -v $(pwd)/libhiredis.so:/usr/lib/libhiredis.so debian:bookworm-slim ls -lh /usr/lib/libhiredis.so'            }
        }

        stage('5. Publish') {
            steps {
                echo 'Publikacja artefaktów do historii builda...'
                archiveArtifacts artifacts: 'hiredis-paczka.tar.gz', fingerprint: true
            }
        }
    }

    post {
        always {
            echo 'Sprzątanie środowiska (repeatability)...'
            sh 'docker img/image\ prune -f'
            
            sh 'echo "Logi procesu CI/CD" > build_log.txt'
            archiveArtifacts artifacts: 'build_log.txt'
        }
    }
}
```


Czy opublikowany obraz może być uruchomiony bez modyfikacji?

Tak. Obraz hiredis-bldr został zbudowany w oparciu o standardowy Dockerfile.build, co zapewnia przenośność.

- Czy dołączony do jenkinsowego przejścia artefakt, gdy pobrany, ma szansę zadziałać od razu na maszynie o oczekiwanej konfiguracji docelowej?

Tak, dowodem jest to ze w etapie Dploy pobrany z builda plik libhiredis.so został zamontowany do systemu debian:bookworm-slim. Komenda ls -lh potwierdziła, że plik jest widoczny i gotowy do linkowania w systemie operacyjnym.



# Przygotowanie Ansible

1. Utworzenie kolejnej masyzny wirtualnej

- sklonowanie głownej maszyny aby ta druga zajmowała jak najmniej miejsa

![alt text](img/image\\-11.png)

- nadanie nowej maszynie hostname ansible-targett

![alt text](img/image\\-12.png)

- stworzenie użytkownika ansible

![alt text](img/image\\-13.png)

- Dodanie uprawnień admistratora użytkownikowi ansible i zainstalowanie ssh i tar 

![alt text](img/image\\-14.png)

- nadanie adresu ip drugiej maszynie ręcznie aby mozna było ją połączyc z pierwszą ( żeby główna maszyna ją widziała)
nano ./ssh/config

![alt text](img/image\\-15.png)

sprawdzenie czy adres ip został przypisany:

![alt text](img/image\-16.png)

- wymiana kluczy SSH między użytkownikiem w głównej maszynie wirtualnej, a użytkownikiem ansible z nowej

![alt text](img/image\-17.png)

sprawdzenie:

![alt text](img/image\-18.png)

wymiana kluczy przeszła poprawnie, logiwanie ssh 10.0.2.4 nie wymagało hasłą użytkownia ansible