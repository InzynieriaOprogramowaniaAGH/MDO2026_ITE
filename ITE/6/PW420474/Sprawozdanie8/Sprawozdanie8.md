# Sprawozdanie 8
Przemysław Wrona ITE 420474

Celem tego ćwiczenia było nauczenie się automatyzacji deplymentów za pomocą ansible.

Zaczęto od stworzenia drugiej maszyny wirtualnej, z 4 cpu, 4gb, 10gb pamięci, (przy 1gb, 1 cpu, 5gb pamięci VM się zawieszał).
![alt text](2.png)
(Tutaj starszy obraz z wersji jak próbowałem mniejsze wymagania niż wyżej powiedziane, ale gdzieś zgubiłem zdjęcie, potem będzie to widać kiedy będę sprawdzał IPv4)

Na tej maszynie trzeba dodać nowego użytkownika 
![alt text](3.png)

Ustawiamy sudo.
![alt text](5.png)
![alt text](4.png)

Sprawdzamy IP naszych maszyn.
![alt text](6.png)
Tutaj możemy też zauważyć konfigurację systemu którą wcześniej wspomniałem.

Zmieniamy /etc/hosts oraz /etc/cloud/templates/hosts.debian.templ. Mógłbym się bawić inaczej ale tak będzie działać na pewno.
![alt text](7.png)
![alt text](8.png)

Zmieniamy się na usera "ansible" na naszej nowej maszynie
![alt text](9.png)
i dodajemy klucze z głównej maszyny do ~/.ssh/authorized_keys



Teraz nasz ansible ma możliwość się połączyć z nową maszyną.

Tworzymy folder do naszego ansible, w nim po koleji ansible.cfg, inventory.ini oraz wykonujemy polecenie ansible-galaxy roles init abralang_deploy, co tworzy naszą rolę odpowiedzialną za całe zachowanie.

Do inventory.ini:
![alt text](10.png)

Do ansible.cfg:
![alt text](11.png)


W tym stworzonym podfolderze "abralang_deploy" przechodzimy do tasks/ i edytujemy/tworzymy pliki main.yml, deploy.yml oraz cleanup.yml.

main.yml:
![alt text](15.png)

cleanup.yml
![alt text](16.png)

deploy.yml oraz site.yml:
![alt text](17.png)



Testujemy łączność (ping normalny oraz poprzez ansible)
![alt text](13.png)
![alt text](14.png)


Teraz testujemy ansible playbook 
![alt text](20.png)

I viola działa.

