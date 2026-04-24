# 1. Konfiguracja SCM i Ścieżka Krytyczna
Zrezygnowano z wklejania skryptu bezpośrednio w interfejs Jenkinsa. Skonfigurowano zadanie tak, aby pobierało definicję Pipeline bezpośrednio z repozytorium Git.
![](img/scm.png)
![](img/repozytorium.png)
![](img/jenkinsfile.png)
# 2. Przygotowanie i czyszczenie środowiska
W pierwszym etapie pipeline'u zadbano o wyczyszczenie katalogu roboczego. Dzięki temu mamy pewność, że proces budowania startuje na "czystym" kodzie pobranym z SCM, a pozostałości z poprzednich buildów nie wpłyną na wynik końcowy.
![](img/czyszczenie.png)
# 3. Etap Build: Obraz budujący i artefakty
W etapie Build obraz list-build przeprowadził kompilację źródeł, tworząc bibliotekę statyczną libclibs_list.a
![](img/build.png)
# 4. Etap Test: Uruchomienie testów jednostkowych
Uruchomiono testy jednostkowe wewnątrz kontenera.
![](img/test.png)
# 5. Etap Deploy: Przygotowanie lekkiego artefaktu
Etap Deploy potwierdził sukces operacji. Artefakt został przeniesiony do finalnego obrazu, co potwierdza komunikat DEPLOY OK oraz listing pliku.
![](img/deploy.png)
# 6. Etap Publish: Wysyłka obrazu do Docker Hub
Obraz został otagowany i wypchnięty do Docker Hub; logi wskazują na publikację obrazu w rejestrze
![](img/publish.png)
# 7. Archiwizacja artefaktów
Biblioteka libclibs_list.a została wyprowadzona z kontenera i zarchiwizowana w Jenkinsie.
![](img/artefakty.png)
# 8. Potwierdzenie działania
Pipeline przechodzi pomyślnie przez wszystkie zdefiniowane etapy:
![](img/potwierdzenie_dzialania.png)
# 9. Uruchomienie pipeline'u po raz kolejny
Pipeline został uruchomiony po raz kolejny.
Pomiędzy przebiegami wprowadzono zmianę w repozytorium i wykonano commit oraz push.
Drugi przebieg pipeline’u pobrał nową rewizję kodu, co potwierdza, że Jenkins nie korzysta z cache, lecz pracuje na aktualnym kodzie z SCM.
![](img/uruchomienie_kolejny_raz.png)

# 10. "Definition of done" 
Opublikowany obraz został pobrany z rejestru poleceniem docker pull, a następnie uruchomiony lokalnie poleceniem docker run. Test potwierdził, że obraz działa poza środowiskiem Jenkins, bez modyfikacji.
![](img/pobranie_obrazu.png)