1. Pobranie repozytroium express
a. Sklonowanie

<img width="945" height="163" alt="image" src="https://github.com/user-attachments/assets/e501ff13-1d86-4918-9d87-2e62505cd135" />

b. Instalacja zależności i testy

<img width="945" height="129" alt="image" src="https://github.com/user-attachments/assets/5f3a5229-2d7c-4e77-8500-bbce991181dc" />
<img width="563" height="164" alt="image" src="https://github.com/user-attachments/assets/395dcbd6-fd39-4387-99bf-bf2d8f535cd0" />


3. Uruchomienie czystego kontenera
a. Uruchomienie kontenera
-it - połączenie dwóch flas - i- sprawia, że wejście kontenera zostaje otwarte, -t przydziela wirtualny terminal, Node:18 - obraz bazowy

<img width="945" height="282" alt="image" src="https://github.com/user-attachments/assets/b721a2d3-1b38-4634-84c1-aa97eb68006c" />


b. Aktualizacja i instalacja gita (jeśli nie ma)

<img width="939" height="194" alt="image" src="https://github.com/user-attachments/assets/b38e09d6-e3cc-4853-8301-df48870cac6d" />


c. Klonowanie

<img width="892" height="222" alt="image" src="https://github.com/user-attachments/assets/67d5b5bc-6e65-4c22-bf65-63830704b2cb" />

d. Budowanie

<img width="945" height="158" alt="image" src="https://github.com/user-attachments/assets/66116d1c-83f2-46f2-8691-f5d34c1e88a1" />

e. Testy i wyjście

<img width="770" height="267" alt="image" src="https://github.com/user-attachments/assets/6f8be523-7546-460f-85c6-ac16f8b34f02" />


3. Automatyzacja - pliki Dockerfile
a. Dockerfile przygotowujący środowisko i budujący aplikacje:
Dockerfile.build

<img width="638" height="311" alt="image" src="https://github.com/user-attachments/assets/f10c042f-34d6-4d83-a09b-e4b6638070fe" />


b. Dockerfile bazujący na wczesniejszym, uruchamia testy

<img width="300" height="147" alt="image" src="https://github.com/user-attachments/assets/eba61cef-8208-4a59-84a2-d05b5547fb30" />


c. Budowanie obrazu bazowego

<img width="528" height="72" alt="image" src="https://github.com/user-attachments/assets/95544907-b60a-4894-9991-2378a5e4e70f" />
<img width="945" height="232" alt="image" src="https://github.com/user-attachments/assets/b91eb5bf-feab-41c0-aedc-2e4f60e171b6" />

d. Budowanie obrazu testowego

<img width="945" height="317" alt="image" src="https://github.com/user-attachments/assets/13df04eb-095f-4334-9c3b-a16644ee0c54" />

e. Uruchomienie kontenera testowego

<img width="466" height="78" alt="image" src="https://github.com/user-attachments/assets/1f57dacf-bcd8-432b-a44c-ac84311be882" />
<img width="600" height="253" alt="image" src="https://github.com/user-attachments/assets/c8742161-c7bc-4113-9c89-980277a7fec7" />


f. Weryfikacja stanu kontenera po zakończeniu procesu


<img width="945" height="81" alt="image" src="https://github.com/user-attachments/assets/d6e7feb8-bd80-4f8b-b0cd-20854276927a" />

Exited(0) - oznacza, że proces wewnątrz kontenera zakończył się sukcesem
