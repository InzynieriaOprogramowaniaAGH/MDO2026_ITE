# Zajęcia 08 – Ansible: poradnik krok po kroku

---

## CZĘŚĆ 1: Druga maszyna wirtualna (ansible-target)

### Krok 1: Utwórz minimalną VM

![alt text](image.png)

### Krok 2: Sprawdź hostname

![alt text](image-1.png)

### Krok 3: Zrób migawkę VM

![alt text](image-2.png)
---

## CZĘŚĆ 2: Ansible na głównej maszynie

### Krok 5: Zainstaluj Ansible

![alt text](image-3.png)

![alt text](image-4.png)

# Weryfikacja:

![alt text](image-5.png)

### Krok 6: Znajdź IP maszyny ansible-target

![alt text](image-6.png)


### Krok 7: Dodaj wpis do /etc/hosts na głównej maszynie

![alt text](image-7.png)

### Krok 8: Wymień klucze SSH

![alt text](image-8.png)

---

## CZĘŚĆ 3: Inwentaryzacja

### Krok 9: Ustaw hostname na głównej maszynie

![alt text](image-9.png)
![alt text](image-10.png)

   
### Krok 10: Stwórz plik inwentaryzacji

![alt text](image-12.png)

### Krok 11: Wyślij ping do wszystkich maszyn

![alt text](image-11.png)

---

## CZĘŚĆ 4: Playbook – zdalne wywoływanie procedur

### Krok 12: Stwórz główny playbook
![alt text](image-13.png)

### Krok 13: Uruchom playbook

![alt text](image-14.png)


### Krok 14: Ponów operację i porównaj wyniki

![alt text](image-15.png)

Przy ponownym uruchomieniu zadanie kopiowania pliku pokaże `ok` zamiast `changed` – Ansible jest idempotentny.
![alt text](image-16.png)

---

## CZĘŚĆ 5: Zarządzanie artefaktem (kontener Express)

Artefaktem z pipeline'u jest kontener `express-prod:5.2.1`.

### Krok 15: Playbook instalujący Dockera na ansible-target
![alt text](image-17.png)

![alt text](image-18.png)

### Krok 16: Playbook wdrażający kontener Express

![alt text](image-19.png)

---

## CZĘŚĆ 6: Rola Ansible (ansible-galaxy)

### Krok 17: Utwórz szkielet roli

![alt text](image-20.png)

![alt text](image-21.png)

### Krok 18: Wypełnij meta/main.yml

![alt text](image-22.png)

### Krok 19: Wypełnij tasks/main.yml
![alt text](image-23.png)

### Krok 20: Wypełnij defaults/main.yml

![alt text](image-24.png)

### Krok 21: Playbook używający roli

![alt text](image-25.png)
![alt text](image-26.png)
