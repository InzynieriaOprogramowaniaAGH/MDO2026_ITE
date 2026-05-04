# Sprawozdanie 8
Autor: Jan Pawelec

---

# Instalacja zarządcy Ansible
Postawiono drugą maszynę o nazwie `ansible-target`. Wybrano Ubuntu server w wersji zminimalizowanej. Połączenie uzyskano za pomocą SSH. Utworzono migawkę.
![alt text](0_ansible_dziala.png)

Następnie połączono maszyny po SSH bez potrzeby podawania hasła.
![alt text](0_ssh_bez_hasla.png)

Sprawdzono czy maszyna główna może komunikować się z `ansible-target`.
![alt text](0_ansible_ping.png)

---

# Inwentaryzacja
Przypisano nazwy do adresów hostów na obu maszynach.
![alt text](1_hostname.png)

Utworzono plik `hosts.ini`, a następnie przetestowano łączność między maszynami.
![alt text](1_host_ping.png)

---

# Zdalne wywoływanie procedur
Utworzono plik `playbook.yml`, w którym zdefiniowano wymagane procedury. 

Przeprowadzono pierwsze uruchomienie. Szereg poleceń wywołano za pomocą `ansible-playbook -i hosts.ini playbook.yml`. Widoczne jest na żółto `changed`, co oznacza że narzędzie dokonało zmian na docelowym hoście. Playbook wykonywał się dosyć długo. Finalnie po zakończeniu widoczny jest sukces z pominięciem pakietu `rngd`, który został pominięty. Nie był on wylistowany w wymaganiach `ansible-target`, więc ten go nie posiada, a co za tym idzie nie będzie aktualizowany. Ansible zachował się prawidłowo, ignorując tę przypadłość.
![alt text](2_1.png)

Następnie ponowiono zestaw operacji. Potrwał znacznie krócej. W tej iteracji nie dokonano zmian takich jak kopiowanie i aktualizacja pakietów, gdyż Ansible sprawdził przed wykonaniem czynności czy istnieje taka potrzeba. Jako że w poprzedniej próbie pobrano wszelkie pakiety, system wydrukował `ok` i jedynie zrestartował SSHD.
![alt text](2_2.png)

Wyłączono serwer SSH (wyłączając także `ssh.socket` za pomocą `sudo systemctl stop ssh.socket ssh.service`), ponownie wywołano playbook. Próba zakończyła się niepowodzeniem.
![alt text](2_3.png)

Odpięto kabel sieciowy (w ustawieniach maszyny), ponownie wywołano playbook. Pojawił się taki sam błąd jak w poprzedniej próbie.
![alt text](2_4.png)

---

# Zarządzanie stworzonym artefaktem
Stworzono role `cjosn_deploy` i przeredagowano `meta/main.yml`.
![alt text](3_galaxy_role.png)

Umieszczono najnowszy artefakt w katalogu `files` (dodano do `.gitignore`). Stworzono pliki `tasks/main.yml` (definicja procesu) i `deploy.yml` (playbook). Uruchomiono listę procedur. Natrafiono na błędy I/O podczas operacji na systemie plików Dockera, co uniemożliwiało ukończenie poprawne kompilacji. Przeprowadzono wiele prób, testując różne opcje, co finalnie doprowadziło do dostarczenia poprawnie działającej wersji.
![alt text](3_checks.png)
![alt text](3_final.png)



