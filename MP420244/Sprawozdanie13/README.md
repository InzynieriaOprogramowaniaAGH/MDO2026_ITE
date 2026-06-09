# GitHub Actions

Akcje GitHuba to narzędzie do wykonywania czynności przy wykryciu pewnej zmiany w repozytorium. Stanowi efektywny mechanizm wspomagający pracę nad oprogramowaniem.

## Praca z workflow

Do wykonania ćwiczenia zostało stworzone nowe repozytorium:

![Inicjalizacja repozytorium](images/1.%20Inicjalizacja%20repozytorium.png)

Aplikajca znajdująca się na repozytorium to strona, symulująca działanie blogu. Frontend i backend napisane są w typescript i korzystają z bazy danych mysql.

Na GitHubie został utworzony nowy branch `ino_dev`:

![Nowy branch](images/2.%20Nowy%20branch.png)

Żeby dodać nową akcję, należy przejść do zakładki `Actions` i wybrać podświetlony tekst `set up a workflow yourself`:

![Nowy workflow](images/3.%20Nowy%20workflow.png)

Należy wybrać odpowiedni branch dla akcji (po lewej stronie), gdyż dotyczy ona tylko jednej gałęzi, którą domyślnie jest `main`. Nazwa akcji jest dowolna:

![Konfiguracja akcji](images/4.%20Konfiguracja%20akcji.png)

*kod akcji w files/verification.yml*

<details open>
<summary>Wyjaśnienie kodu akcji</summary>

* `name`: nazwa akcji;
* `on`: czynności wywołujące akcję, tu - push na branch `ino_dev`;
* `jobs`: operacje do wykonania przez akcję;
* `steps`: zdefiniowane kroki wykonujące polecenia terminala.

Co robi akcja (jobs + steps):
* uruchamia kontener z bazą danych mysql;
* konfiguruje zmienną środowiskową z adresem bazy;
* uruchamia node v20;
* instaluje zależności backendu i frontendu;
* uruchamia klienta Prismy i wykonuje migrację;
* uruchamia backend i frontend, czekając na każde minutę;
* weryfikuje połączenie poleceniem curl;
* w przypadku niepowodzenia tworzy artefakty z logami;
* oczyszcza środowisko wykonawcze.

</details>

Po dodaniu akcji wykonuje się push, żeby dodać ją do repozytorium:

![Dodanie akcji](images/5.%20Dodanie%20akcji.png)

Wykonanie push na branch liczy się jako zdarzenie, które jest od razu wykryte przez stworzoną akcję, więc wykonuje się ona od razu.

Dodana akcja przechowywana jest w ukrytym folderze `.github/workflows` podobnie jak git hooki w `.git/hooks`:

![Repozytorium po akcji](images/6.%20Repozytorium%20po%20akcji.png)

<details open>
<summary>GitHub Action a Git Hook</summary>
Fundamentalna różnica między akcją a hookiem jest moment wykonania i jego scope. Oba narzędzia służą do wykonywania operacji przy wykryciu odpowiedniej czynności. Git hook będzie wykonywać skrypt przed wysłaniem kodu z repozytorium lokalnego git na zdalne github, dodatkowo obejmując tylko urządzenie lokalne użytkownika. Akcja może wykonywać operacje dopiero po wykryciu pewnej zmiany na zdalnym repozytorium, czyli np. otrzymanie pusha lub pull requesta, i obejmować może tylko to repozytorium. Git hook jest narzędziem do indywidualnych potrzeb, podczas gdy akcja może wyznaczać limity narzucone przez przełożonych.
</details>

Wykonanie push automatycznie uruchamia akcję:

![Log akcji](images/7.%20Log%20akcji.png)

W czasie rzeczywistym dostępny jest podgląd czynności wykonywanych przez akcję.

*log akcji w files/success.log*

## Niepowodzenie akcji

Akcja, podobnie jak git hook, może zakończyć się niepowodzeniem. Świadczy ono zwykle o błędzie w programie, niespełnionych wymaganiach, niezdanych testach, itp. Z tego powodu warto zapisywać logi wydarzeń do artefaktów:

![Akcja po niepowodzeniu](images/8.%20Akcja%20po%20niepowodzeniu.png)

*log niepowodzenia akcji w files/backend_fail.log*

Niepowodzenie akcji jest wysyłane jako powiadomienie na GitHubie:

![Wiadomość po niepowodzeniu](images/9.%20Wiadomość%20o%20niepowodzeniu.png)

Otrzymuje się również wiadomość na prywatnej poczcie:

![Mail po niepowodzeniu](images/10.%20Mail%20o%20niepowodzeniu.png)

Są to bardzo przydatne funkcje podczas pracy nad dużym projektem. Akcje weryfikujące program mogą zająć dużą ilość czasu, więc otrzymywanie powiadomień zapobiega konieczności nadzorowania procesu wykonywania.