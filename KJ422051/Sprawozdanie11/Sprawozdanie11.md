Przygotowanie obrazów:

Prosta strona WWW na bazie obrazu nginx:

Wersja 1:

Dockerfile:

<img width="881" height="145" alt="image" src="https://github.com/user-attachments/assets/1aa0ff49-cd49-47b7-bf47-9e702b85c98b" />

<img width="934" height="377" alt="image" src="https://github.com/user-attachments/assets/7be3effc-99a5-48e1-8dbf-f4a8cf7d8651" />



Analogicznie wersja 2 z zmienionym tekstem.

Wersja 3 – wadliwa:

<img width="806" height="152" alt="image" src="https://github.com/user-attachments/assets/784cb1a4-233f-4f2b-8748-bb8269b10780" />

Skalowanie Deploymentu:

Zmiana pliku wdrożenie.yaml z poprzednich zajęć:

<img width="378" height="202" alt="image" src="https://github.com/user-attachments/assets/0de21b30-2261-4c1a-aa8a-0b0a584fc30d" />

Po uruchomieniu rozpoczęto serię skalowań:
Liczba replik = 8:

<img width="945" height="974" alt="image" src="https://github.com/user-attachments/assets/cc2f2a0a-b98d-442f-a697-5945777b176f" />

Liczba replik 1:

<img width="489" height="263" alt="image" src="https://github.com/user-attachments/assets/cc4b98da-e12d-4283-9185-08b8fa1b7ff7" />


Liczba replik 0:

<img width="716" height="528" alt="image" src="https://github.com/user-attachments/assets/efa7ebeb-ff5e-4b84-8139-9c163aadbbdf" />

Liczba replik 4:

<img width="606" height="648" alt="image" src="https://github.com/user-attachments/assets/c2d09f94-fca0-4ea6-94e2-2c52d98889bb" />

Skalowanie wykonano za pomocą komendy:  kubectl scale deployment wdrozenie --replicas=

Zastosowanie wersji 2:

<img width="945" height="41" alt="image" src="https://github.com/user-attachments/assets/f129beb3-d2cd-4b93-a035-28e929c22ae6" />

<img width="522" height="670" alt="image" src="https://github.com/user-attachments/assets/ba5abc3a-9b33-41fe-8f43-e524237665d0" />

Zastosowanie wersji wadliwej:

<img width="945" height="54" alt="image" src="https://github.com/user-attachments/assets/31cd0041-383b-4115-af0e-832ad1e4560e" />

<img width="539" height="420" alt="image" src="https://github.com/user-attachments/assets/264b807c-d160-4c16-90d2-c599781d377f" />

Sprawdzenie błędów:

<img width="842" height="172" alt="image" src="https://github.com/user-attachments/assets/355511b4-8039-4241-9149-45292498ef7a" />

Historia wdrożeń:

<img width="383" height="203" alt="image" src="https://github.com/user-attachments/assets/e3fc28ad-0f5d-4b74-b8a3-6c2e065963a4" />

Cofnięcie do ostatniej działającej wersji: 

<img width="945" height="55" alt="image" src="https://github.com/user-attachments/assets/6e67df6b-d7e6-4bb8-b7ad-9843a869bcc3" />

<img width="488" height="392" alt="image" src="https://github.com/user-attachments/assets/feb1f570-c907-436c-b036-26964dd4cbf9" />

Skrypt weryfikujący:

<img width="945" height="241" alt="image" src="https://github.com/user-attachments/assets/8616f4db-487b-49f1-8ad0-818a0f30f57e" />

Wyniki:

<img width="944" height="228" alt="image" src="https://github.com/user-attachments/assets/21431d47-9839-4deb-bf00-7cbff7a2c75a" />

Strategie wdrożenia:

Recreate:

<img width="919" height="603" alt="image" src="https://github.com/user-attachments/assets/69224c2d-9043-41a3-b87a-59039d817fe2" />

Ta strategia najpierw zabija wszystkie stare pody, a dopiero gdy znikną, tworzy nowe. Powoduje to krótką przerwę w działaniu.

<img width="555" height="1130" alt="image" src="https://github.com/user-attachments/assets/fff6359a-815e-4d50-ab1d-3cdeb5aeeef8" />

Rolling Update:
Domyślna strategia. Pody są wymieniane stopniowo:

<img width="828" height="669" alt="image" src="https://github.com/user-attachments/assets/01e0d50c-f448-4cd7-a9f2-bcd35805dc13" />

<img width="539" height="994" alt="image" src="https://github.com/user-attachments/assets/a230caad-289f-4bd5-8c6d-658d3351194d" />

Canary Deployment:

Polega na uruchomieniu dwóch osobnych wdrożeń podpiętych pod ten sam serwis.

Wersja stabilna:

<img width="883" height="592" alt="image" src="https://github.com/user-attachments/assets/8cd21222-252b-48a2-977f-c9b29cfafbfc" />

Wersja nowa – „karanek”:
<img width="855" height="586" alt="image" src="https://github.com/user-attachments/assets/f71866e4-243b-4d00-bcad-a0964b15ec82" />

Serwis łączący wdrożenia:

<img width="853" height="347" alt="image" src="https://github.com/user-attachments/assets/a62982b2-1ce9-4879-85b0-ff7973436339" />


Uruchomienie:

<img width="945" height="154" alt="image" src="https://github.com/user-attachments/assets/a228a031-39cd-4bbb-b60a-e5aa974f209f" />

<img width="563" height="1059" alt="image" src="https://github.com/user-attachments/assets/8b24ab45-8d90-4ffc-8ffd-3fa201ee598b" />

<img width="758" height="288" alt="image" src="https://github.com/user-attachments/assets/ba0dbe96-0001-4203-988c-0a3eb578c3dd" />
