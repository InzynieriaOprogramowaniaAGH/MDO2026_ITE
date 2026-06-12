1. Instalacja klastra Kubernetes

    * instalacja minikube

    * zaopatrzenie się w polecenie kubectl

    ![alt text](img/image.png)

2. Zbudowanie klastra Kubernetes z wykorzystaniem dockera

    ```{groovy}
    minikube statr --driver=docker
    ```

    ![alt text](img/image-1.png)
 

3. Weryfikacja działania workera 

    ![alt text](img/image-2.png)

4. Uruchomienie Dashboardu

    ![alt text](img/image-3.png)

5. Wdrożenie pierwszej aplikacji (moj-nginx)

    ![alt text](img/image-4.png)

    * sprawdzenie stanu aplikacji, czy kontener faktycznie pracuje

        ![alt text](img/image-5.png)
 
6. Przekierowanie portu (8888 -> 80)

    * udowowdnienie komunikacji 

    ```{groovy}
    curl http:/localhost:8888
    ```

    ![alt text](img/image-6.png)

 
7. Utworzenie pliku wdrożenia (yml)
 
    ![alt text](img/image-7.png)

    * Uruchomienie wdrożenia

        ![alt text](img/image-8.png)
 
    * Sprawdzenie statusu za pomocą 
        ```{groovy} 
        kubel rollout status deployment moje-wdrozenie
        ```

        dla upewniena sie czy napewno są 4 działające aplikacje na raz (+ moja pierwsza aplikacja moj-nginx)
        ```{groovy}
        kubectl get pods
        ```
        ![alt text](img/image-9.png)
 

8. Wyeksponowanie wdrożenia na serwis

    ![alt text](img/image-10.png)
 
9. Przekierowanie portu (do serwisu 9999 -> 80)

    ![alt text](img/image-11.png)

10. Ostateczny wygląd Kubernates Dashboard

    ![alt text](img/image-12.png)
    ![alt text](img/image-13.png)
 
    Wszystko działa poprawnie

 
