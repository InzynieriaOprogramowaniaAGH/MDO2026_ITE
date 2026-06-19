## Cel laboratorium: 
Celem zadania było zapoznanie się z usługą GitHub Actions oraz praktyczna implementacja 
koncepcji Shift-left (wczesnego testowania i budowania oprogramowania w cyklu życia 
projektu). 
## Fork i klon repozytorium:  
Na obiekt testowy wybrano projekt antirez/kilo – lekki edytor tekstu napisany w języku C. Projekt 
ten kompiluje się bardzo szybko, co gwarantuje optymalne wykorzystanie darmowych minut z 
planu rozliczeniowego GitHub Actions. 
Repozytorium zostało sforkowane na konto, a za pomocą narzędzia GitHub CLI (gh repo set
default) ustawiono je jako domyślne do zarządzania akcjami z poziomu terminala. 
## Sprawdzenie, czy są workflows: 
Zweryfikowano również, że w oryginalnym projekcie nie było zdefiniowanych żadnych 
wcześniejszych potoków CI/CD (brak katalogu .github/workflows/),  co pozwala na stworzenie 
akcji od podstaw. 
## Stworzenie gałęzi: 
Utworzono i przełączono się na dedykowaną gałąź ino_dev, na której będą wprowadzane zmiany 
i konfigurowane nowe akcje. 
## Workflow 1 – build przy push do gałęzi 
Utworzono pierwszy potok CI. Jego działanie opiera się na trzech głównych założeniach: 
• Wyzwalacz (Trigger): Akcja jest uruchamiana w momencie wystąpienia 
zdarzenia push wyłącznie dla gałęzi ino_dev. 
• Zadania: Środowisko bazuje na najnowszym systemie Ubuntu (ubuntu-latest). Po 
pobraniu kodu, wywoływane jest polecenie make, które buduje projekt z kodów 
źródłowych. 
• Artefakt: Dodano krok wykorzystujący akcję actions/upload-artifact@v4.  
## Workflow 2 – własne kryterium 
Utworzono drugi, niezależny potok realizujący podejście Shift-left. 
• Wyzwalacz (Trigger): W tym przypadku wyzwalaczem jest 
zdarzenie pull_request kierowane do gałęzi ino_dev. 
• Zadania: Potok odpowiada za analizę kodu C. W pierwszej kolejności środowisko 
instaluje narzędzie cppcheck, a następnie uruchamia statyczną analizę kodu załączając 
odpowiednie flagi weryfikujące błędy i ostrzeżenia (--enable=warning,style --error
exitcode=0). 
## Ustawienie repozytorium: 
Za pomocą narzędzia GitHub CLI przypisano sforkowane repozytorium jako domyślne dla 
bieżącego katalogu. Było to konieczne, ponieważ GitHub CLI automatycznie łączył się z 
oryginalnym repozytorium. 
## Test: 
Nowo utworzone pliki konfiguracyjne potoków zostały dodane do poczekalni, zacommitowane 
oraz wypchnięte (push) na zdalną gałąź ino_dev. To zdarzenie powinno automatycznie wyzwolić 
Workflow 1. 
## Weryfikacja: 
Sprawdzono status wykonania akcji. Tabela potwierdza, że potok "Build" został poprawnie 
uruchomiony po zdarzeniu push i zakończył się sukcesem (zielony znacznik). 
Pomyślnie zweryfikowano logi z wykonania potoku. Pokazują one bezbłędne przypisanie 
środowiska uruchomieniowego, wykonanie polecenia make i zarchiwizowanie artefaktu. 
## Sprawdzenie artefaktu: 
Aby udowodnić poprawne wygenerowanie artefaktu, pobrano go za pomocą komendy gh run 
download z odpowiednim identyfikatorem. Polecenie ls potwierdza obecność pobranego 
katalogu ze skompilowanym plikiem binarnym edytora Kilo. 
## Przetestowanie workflow 2: 
Aby przetestować potok weryfikujący jakość kodu przed włączeniem go do głównej gałęzi, 
utworzono gałąź eksperymentalną ino_dev-test i wprowadzono w niej celową zmianę w kodzie 
źródłowym. 
## Weryfikacja: 
Natychmiast po otwarciu PR sprawdzono listę akcji. Widoczny jest uruchomiony potok "Code 
Quality", wynikający ze zdarzenia pull_request, który w tym momencie był w trakcie 
analizowania kodu (status *). 
Po kilkunastu sekundach akcja zakończyła się sukcesem. Kod został pomyślnie poddany 
analizie statycznej, co dowodzi poprawnej i pełnej implementacji mechanizmów CI zgodnie z 
koncepcją Shift-left. 
## Podsumowanie 
Zbudowano w pełni zautomatyzowane środowisko, które samodzielnie kompiluje projekt po 
każdej zmianie w kodzie oraz generuje i archiwizuje gotowe do pobrania artefakty. 
Najważniejszym wnioskiem płynącym z ćwiczenia jest skuteczność wdrożonego paradygmatu 
Shift-left. Przeniesienie testów i statycznej analizy kodu (za pomocą narzędzia cppcheck) na 
sam początek cyklu życia – bezpośrednio do etapu tworzenia Pull Requesta – udowadnia, jak 
skutecznie i automatycznie można zapobiegać integracji usterek z główną gałęzią projektu. 
Ponadto, realizacja całego zadania z poziomu interfejsu wiersza poleceń (Git oraz GitHub CLI) 
potwierdza dużą elastyczność i kontrolę, jaką dają nowoczesne narzędzia deweloperskie bez 
konieczności używania interfejsu graficznego przeglądarki. x
