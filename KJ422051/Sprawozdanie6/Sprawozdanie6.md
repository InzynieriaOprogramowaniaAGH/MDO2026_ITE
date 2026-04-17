Wybór aplikacji
Express.js
Wybrano aplikację webową opartą na frameworku Express.js. Jest to prosta aplikacja typu 'Hello World'. Kod udostępniony jest na licencji MIT, co pozwala na jego swobodne użycie i modyfikację w celach edukacyjnych.

<img width="647" height="328" alt="image" src="https://github.com/user-attachments/assets/1b97aab8-ddc7-49d8-837c-e3aef00f27b2" />

Diagram aktywności:

<img width="755" height="1175" alt="image" src="https://github.com/user-attachments/assets/d559eb3d-0028-4b36-ab35-c4d138759871" />


Diagram wdrożeniowy:

<img width="875" height="431" alt="image" src="https://github.com/user-attachments/assets/1a71a382-849b-4893-9755-db8bb460342b" />

Dockerfile.build – kontener Builder I Tester

<img width="314" height="283" alt="image" src="https://github.com/user-attachments/assets/a9cb608c-19d9-4b05-8029-c2c186cc3f58" />

Dockerfile.runtime – kontener Deploy

<img width="441" height="331" alt="image" src="https://github.com/user-attachments/assets/bc8889fb-dbe3-4f73-8ae9-7a8b66aa0c69" />

Wybrano obraz node:18-alpine dla etapu budowania, ponieważ jest on zoptymalizowany pod kątem rozmiaru, a jednocześnie zawiera niezbędne narzędzia do instalacji zależności i uruchomienia testów. Dla etapu wdrożenia (runtime) wybrano node:18-slim. Różnica polega na tym, że wersja 'slim' jest oparta na pełniejszym systemie (Debian), ale pozbawiona zbędnych pakietów, co zapewnia większe bezpieczeństwo produkcyjne i stabilność przy zachowaniu małego rozmiaru.

Jenkinsfile

<img width="945" height="781" alt="image" src="https://github.com/user-attachments/assets/e8365db4-6974-43f9-8a69-2d708fb5eeeb" />

<img width="945" height="643" alt="image" src="https://github.com/user-attachments/assets/f31eab2e-09c0-4170-8d9e-e70f1d2d4971" />

Program jest dystrybuowany w dwóch formach: jako wersjonowany obraz Docker oraz jako archiwum tar.gz. Zdecydowano się na archiwum tar.gz, ponieważ jest to standardowy format redystrybucyjny dla Node.js, łatwy do przesłania na dowolny serwer. 

Dodano pliki do repozytorium:

<img width="945" height="243" alt="image" src="https://github.com/user-attachments/assets/ff3334b1-6357-4b1f-a7d8-a9473ac97fd9" />

Połączenie na Jenkins z repozytrium

Dodano brakujący plik app.js do github

<img width="945" height="305" alt="image" src="https://github.com/user-attachments/assets/9302a613-86c8-412a-b55c-d3955b47ef60" />

<img width="878" height="1231" alt="image" src="https://github.com/user-attachments/assets/7eb2f019-c34c-4bbc-b31d-c659c3d5ce50" />

Zakończenie sukcesem:

<img width="945" height="221" alt="image" src="https://github.com/user-attachments/assets/242f431a-8fb0-480b-8fb6-1a1aa102e6ad" />


