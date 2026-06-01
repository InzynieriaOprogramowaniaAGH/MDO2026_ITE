Rejestrowanie nowej wersji obrazu:

![alt text](<image1.png>)

![alt text](<image2.png>)

![alt text](<image3.png>)

Tagowanie obrazu:

![alt text](<image4.png>) 

Sprawdzanie czy działa:

![alt text](<image5.png>) 

Tworzenie obrazu z błędem:

![alt text](<image6.png>) 

![alt text](<image7.png>) 

Tagowanie i sprawdzanie działania:

![alt text](<image8.png>) 

Pushowanie obrazu na Dockerhub: 

![alt text](<image9.png>) 

Zmiany w pliku .yaml:
zwiększenie replik do 8:

![alt text](<image10.png>) 

![alt text](<image11.png>) 

Zmniejszenie replik do 1:

![alt text](<image12.png>) 

Zmniejsznie replik do 0:

![alt text](<image13.png>) 

Zwiększenie replik do 4:

![alt text](<image21.png>) 

Wprowadzenie nowego obrazu:

![alt text](<image14.png>) 

Wprowadzenie nowego obrazu z błędem:

![alt text](<image16.png>) 

Badanie obrazu z błędem:

![alt text](<image17.png>) 
![alt text](<image18.png>) 

Rollout oraz zastosowanie starszej wersji obrazu:

![alt text](<image15.png>) 

Sprawdzanie histori rolloutów:

![alt text](<image19.png>)

Cofnięcie rolloutu:

![alt text](<image20.png>) 

Historia wdrożenia i problemy:
W trakcie testów każda modyfikacja pliku YAML i ponowne kubectl apply generowała nową rewizję w kubectl rollout history. Skalowanie replik było rejestrowane jako kolejne rewizje Deploymentu: przy replicas 0 Service tracił endpointy i usługa była niedostępna, lecz rollout formalnie się kończył. Po przywróceniu co najmniej 4 replik pody wracały do stanu Running. Zmiana obrazu na nowszą wersję oraz powrót do starszej przebiegały zgodnie ze strategią, natomiast wdrożenie obrazu wadliwego powodowało CrashLoopBackOff oraz zatrzymanie rolloutu.

Skrypt do sprawdzania czy wdrożenie się powiodło w 60 sekund:

![alt text](<image22.png>) 

Uruchomienie skryptu:

![alt text](<image23.png>) 

Skrpyt ujęty w pipeline:

![alt text](image.png)

Wersej wdrożeń:
canary:

![alt text](<image24.png>) 

![alt text](<image25.png>) 

![alt text](<image26.png>) 

![alt text](<image27.png>) 

![alt text](<image28.png>) 

Rolling:

![alt text](<image29.png>) 

![alt text](<image30.png>) 

Recreate:


![alt text](<image31.png>) 

![alt text](<image32.png>) 

Sprawdzanie stanów wdrożenia:

![alt text](<image33.png>)

Różnice między wersjami wdrożeń:
Rolling Update: aktualizacja odbywa się stopniowo poprzez wymianę kolejnych replik, przy czym część instancji poprzedniej wersji pozostaje dostępna w trakcie wdrożenia, co minimalizuje przestoje usługi.

Recreate: przed uruchomieniem nowej wersji wszystkie repliki poprzedniej wersji są usuwane, a następnie tworzone są instancje nowej wersji; strategia ta powoduje krótkotrwałą niedostępność usługi, ale eliminuje równoległe działanie obu wersji w ramach jednego obiektu Deployment.

Canary: nowa wersja jest wdrażana równolegle ze stabilną w osobnych obiektach Deployment, a na instancje testowe kierowany jest ograniczony ruch produkcyjny, co umożliwia weryfikację poprawności wdrożenia przed pełnym przełączeniem całego obciążenia na nową wersję.



