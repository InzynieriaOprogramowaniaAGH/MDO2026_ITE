# Plik odpowiedzi

Utworzenie i uruchomienie po raz pierwszy maszyny wirtualnej serwera Fedora generuje plik anaconda-ks.cfg w katalogu `/root`. Można wykorzystać go jako szkielet do własnej konfiguracji nienadzorowanej instalacji.

Przygotowany został plik kickstart do uruchomienia kontenera obrazu, utworzonego przez Jenkins pipeline na poprzednich laboratoriach. Udostępnić go można przez lokalny serwer HTTP, uruchomiony w powłoce hosta:

![Serwer HTTP](images/1.%20Serwer%20HTTP.png)

Należy zadbać o to, żeby serwer postawiony był w katalogu z plikiem kickstart.

W Oracle VirtualBox należy stworzyć maszynę w następujący sposób:

![Konfiguracja VM](images/2.%20Konfiguracja%20VM.png)

Wymagane jest podanie pliku ISO i, wbrew pozorom, **odznaczenie** opcji nienadzorowanej instalacji. Dzięki temu nie trzeba tworzyć w ustawieniach maszyny nowego użytkownika z hasłem - to zadanie należy do pliku odpowiedzi.

Uruchamiając maszynę wirtualną, wpierw pokaże się GRUB:

![Grub](images/3.%20Grub.png)

Należy wcisnąć przycisk **E** na klawiaturze by wejść do konfiguracji uruchomienia. Dopisać trzeba następującą linijkę: `inst.ks=http://<adres hosta>:<udostępniony port>/<lokalizacja pliku>`

![Boot script](images/4.%20Boot%20script.png)

Ważnym jest wpisanie tego fragmentu w linijkę polecenia `linux` - inaczej, zostanie ono zignorowane.

Potwierdzenie wprowadzonych danych odbywa się poprzez wciśnięcie **F10** lub kombinacji **CTRL+X**. Wtedy rozpoczyna się instalacja:

![Instalacja pakietów](images/6.%20Instalacja%20pakietów.png)

Pobranie pliku kickstart z serwera jest widoczne w powłoce hosta:

![Pobieranie pliku kickstart z serwera](images/5.%20Pobieranie%20pliku%20kickstart%20z%20serwera.png)

Widać na nim m.in. adres maszyny wirtualnej w sieci, typ i datę wysłania żądania HTTP, pobrany plik i kod zwrotny.

Kiedy instalacja zakończy się, maszyna uruchomi się ponownie. Powinien ukazać się ten sam GRUB co na początku. Należy wyłączyć maszynę i przejść do jej ustawień.

Żeby maszyna korzystała z przeprowadzonej instalacji, należy umieścić dysk twardy jako pierwsze (lub jedyne) urządzenie uruchamiania:

![Kolejność uruchamiania](images/7.%20Kolejność%20uruchamiania.png)

Niekoniecznie, choć dla pewności, można też usunąć plik ISO z pamięci:

![Urządzenia VM](images/8.%20Urządzenia%20VM.png)

Ponowne uruchomienie maszyny ukazuje inny grub niż wcześniej. Oznacza to sukces instalacji i konfiguracji:

![Nowy grub](images/9.%20Nowy%20grub.png)

Po wybraniu pierwszej opcji, maszyna uruchamia się bez ekranu instalacyjnego:

![Uruchomiony serwer Fedora](images/10.%20Uruchomiony%20serwer%20Fedora.png)

## Weryfikacja skryptu post-instalacyjnego

Streszczenie skryptu bloku `%post`:
* `--log=/root/ks-post.log`: logowanie operacji do podanego pliku;
* `mkdir -p /opt/app`: stworzenie katalogu pod walidację;
* `cat > /usr/local/bin/bootstrap-container.sh << 'EOF'`: zamknięcie skryptu *post* w pliku wykonywalnym;
* `curl -o "$IMAGE_FILE" "$IMAGE_URL"`: pobranie archiwum z tego samego serwera HTTP co plik kickstart;
* `systemctl start docker`: uruchomienie dockera;
* `docker load -i "$IMAGE_FILE"`: stworzenie obrazu z archiwum;
* `echo "$IMAGE_NAME" > /opt/app/image_name.txt`: wpisanie nazwy obrazu do pliku;
* `docker run ...`: uruchomienie kontenera, który wypisuje zawartość swojego katalogu `/app`;
* `chmod +x /usr/local/bin/bootstrap-container.sh`: nadanie plikowi ze skryptem uprawnienia do wykonania;
* `systemctl enable app-bootstrap.service`: uruchomienie skryptu.

Sprawdzona zostaje treść zdefiniowanych plików, by zweryfikować sukces skryptu:

1. Plik z nazwą obrazu `/opt/app/image_name.txt`:

![Nazwa obrazu](images/11.%20Nazwa%20obrazu.png)

2. Log skryptu bloku post `/root/ks-post.log`:

![Log skryptu](images/12.%20Log%20skryptu.png)

3. Plik ze skryptem `/usr/local/bin/bootstrap-container.sh`:

![Plik skryptu](images/13.%20Plik%20skryptu.png)

4. Dziennik zdarzeń `journalctl -u app-bootstrap.service`:

![Dziennik zdarzeń](images/14.%20Dziennik%20zdarzeń.png)

5. Log kontenera `docker logs -f app_container`:

![Log kontenera](images/15.%20Log%20kontenera.png)

Wszystkie pliki repozytorium zostały wypisane, co oznacza poprawne działanie kontenera.