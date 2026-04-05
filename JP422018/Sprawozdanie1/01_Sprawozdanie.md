# 1. Hypervisor - zarządzanie VM'ami. 
* Rozdziela zasoby sprzętowe komputera (RAM, procesor, itd...)
* Pozwala podzielić jeden komputer na wiele systemów

### Typy hypervisora
* Natywne (HyperV, Proxmox) - bezpośrednio na sprzęcie. Na tym samym poziomie co główny system, brak pośredniczącego systemu. 
* Hosted (VirtualBox, VMware) - działa jak zwykła aplikacja na systemie glównym. Mniej wydajne, ale wygodniejsze

#### Dlaczego systemy serwerowe instaluje się bez GUI?
* lekkość i wydajność
* bezpieczeństwo i stabilność - mniej rzeczy się może wywalić

# 2. SSH - protokół komunikacyjny do bezpiecznego zdalnego sterowania innym komputerem
### Po co?
* Nie trzeba robić wycieczek do serwerowni z monitorem, można nim zarządzać laptopem z kanapy.
* Przekierowanie ruchu sieciowego, proxy, omijanie barier

### Autoryzacja
Wykorzystuje się klucze SSH (private/public). Mega bezpieczne i odbywa się automatycznie

### Schemat polaczenia ssh
1. Zainstalowanie i uruchomienie serwera ssh
2. Wygenerowanie pary kluczy
3. Przesłanie klucza publicznego na serwer

# 3. SFTP - przesyłanie plików między komputerami w sieci (SSH+SFTP)
* wgrywanie plików strony
* łatwa automatyzacja przez skrypty
* duże pliki nie są problemem

### Typowe użycie
1. System kadr generuje raport. Bank wystawia do internetu serwer SFTP. Kadrówka sie z nim łączy i wysyła plik przez SFTP.
(Zazwyczaj żeby nie wystawiać serweru "na świat" korzysta się z VPN który łączy dwie sieci w jedną wirtualną sieć LOKALNĄ)

### Najczesciej korzysta sie z nakładek graficznych (WinSCP, FileZilla)

# 4. Git Hooks - Automatyczne skrypty uruchamiane przy określonych zdarzeniach
Może działać lokalnie, w przeciwieństwie go github actions, które działa tylko serwerowo
* Wymóg konkretnego nazewnictwa commit-msg 
* Formatowanie kodu przed commitem
* Wykrywanie wycieku haseł i kluczy przed wysłaniem na serwer
* Zautomatyzowanie mechanizmow po git checkout / git pull np. automatyczne npm install


# Konfiguracja sieciowa VM
### 1. External Switch
VM dostaje własne IP, jest traktowane jako osobne urządzenie i ma dostęp do internetu

### 2. Internal Switch
VM gada tylko z hostem, nie ma dostępu do internetu

### 3. Private Switch
VM może gadać tylko z innymi VM'ami. Nie widzi hosta, ani nie ma dostępu do internetu