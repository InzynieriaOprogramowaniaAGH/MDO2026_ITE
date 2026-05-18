# Sprawozdanie 8: Nienadzorowana instalacja systemu i automatyzacja wdrożenia
**Autor:** Filip Pyrek
**Indeks:** 422032

## 1. Przygotowanie wzorcowego pliku odpowiedzi
Pracę rozpocząłem od przeprowadzenia instalacji systemu Fedora 44, aby wygenerować bazowy plik odpowiedzi `anaconda-ks.cfg`. Po zakończeniu konfiguracji, plik został przesłany na maszynę `devops-main` przy użyciu protokołu SCP. Stał się on fundamentem do dalszej automatyzacji procesu instalacji.

![Pobieranie bazowego pliku odpowiedzi z maszyny wzorcowej](images/UzyskaniePlikuOdpowiedzi.png)

## 2. Modyfikacja pliku odpowiedzi (ks.cfg) pod instalację sieciową
Plik `ks.cfg` został zmodyfikowany zgodnie z wymaganiami instrukcji, aby zapewnić pełną automatyzację:
*   **Repozytoria:** Dodano sekcje `url` oraz `repo` wskazujące na oficjalne serwery Fedory 44, co umożliwiło instalację typu Netinstall.
*   **Hostname:** Skonfigurowano unikalną nazwę hosta `fedora-kalkulator`.
*   **Automatyzacja dysku:** Zastosowano dyrektywę `clearpart --all --initlabel`, co pozwoliło na nienadzorowane czyszczenie dysku przed instalacją.
*   **Pakiety:** Do sekcji `%packages` dopisano pakiet `docker` oraz `curl`.

![Uruchomienie instalacji z parametrem inst.ks](images/UruchomienieZPlikuOdpowiedzi.png)

## 3. Realizacja instalacji nienadzorowanej
Plik odpowiedzi został udostępniony przez serwer HTTP na maszynie Ubuntu. Nowa maszyna wirtualna została uruchomiona z parametrem `inst.ks`, który wskazywał na przygotowaną konfigurację. Instalator samodzielnie przeprowadził partycjonowanie, konfigurację sieci oraz instalację oprogramowania.

![Proces automatycznej instalacji pakietów](images/InstalacjaFedora.png)

Po automatycznym restarcie system uruchomił się z poprawnie skonfigurowaną nazwą hosta, co potwierdziło poprawne przetworzenie pliku odpowiedzi.

![Potwierdzenie poprawnego ustawienia hostname po zalogowaniu](images/UruchomienieZPlikuOdpowiedzi2.png)

## 4. Automatyzacja wdrożenia kontenera (Post-install)
W sekcji `%post` zaimplementowałem mechanizm automatycznego pobrania i uruchomienia aplikacji. Ze względu na to, że usługa Docker nie jest aktywna podczas samej instalacji, stworzyłem skrypt `/usr/local/bin/deploy-app.sh` oraz usługę `systemd`. Mechanizm ten dba o to, by przy każdym starcie systemu stary kontener był usuwany (`docker rm -f`), a nowy uruchamiany na świeżo.

![Weryfikacja uruchomionego kontenera za pomocą docker ps](images/PostawioneOprogramowanie.png)

## 5. Weryfikacja końcowa i test działania
Poprawność wdrożenia zweryfikowałem poprzez dostęp do aplikacji z poziomu przeglądarki na maszynie hosta. Dzięki automatycznej konfiguracji zapory sieciowej (firewall-cmd) w skrypcie post-instalacyjnym, kalkulator stał się dostępny natychmiast po pierwszym uruchomieniu systemu. Potwierdzono poprawne działanie wszystkich funkcji aplikacji w środowisku produkcyjnym.

![Działający kalkulator dostępny pod adresem IP nowej maszyny](images/DzialajaceOprogramowanieLab9.png)