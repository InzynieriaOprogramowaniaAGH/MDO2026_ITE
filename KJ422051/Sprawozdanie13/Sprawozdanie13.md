## Cel laboratorium: 
Celem zadania było zapoznanie się z usługą GitHub Actions oraz praktyczna implementacja 
koncepcji Shift-left (wczesnego testowania i budowania oprogramowania w cyklu życia 
projektu). 
## Fork i klon repozytorium:  
Na obiekt testowy wybrano projekt antirez/kilo – lekki edytor tekstu napisany w języku C. Projekt 
ten kompiluje się bardzo szybko, co gwarantuje optymalne wykorzystanie darmowych minut z 
planu rozliczeniowego GitHub Actions.

<img width="746" height="253" alt="image" src="https://github.com/user-attachments/assets/d8836c55-c7d3-4198-8343-153ff9538061" />


Repozytorium zostało sforkowane na konto, a za pomocą narzędzia GitHub CLI (gh repo set
default) ustawiono je jako domyślne do zarządzania akcjami z poziomu terminala. 
## Sprawdzenie, czy są workflows: 

<img width="704" height="54" alt="image" src="https://github.com/user-attachments/assets/13e2f370-8282-420e-bb88-9190d84874d2" />


Zweryfikowano również, że w oryginalnym projekcie nie było zdefiniowanych żadnych 
wcześniejszych potoków CI/CD (brak katalogu .github/workflows/),  co pozwala na stworzenie 
akcji od podstaw. 
## Stworzenie gałęzi: 

<img width="695" height="37" alt="image" src="https://github.com/user-attachments/assets/fc4f4235-fa1f-49da-be4d-32e306a5e491" />


Utworzono i przełączono się na dedykowaną gałąź ino_dev, na której będą wprowadzane zmiany 
i konfigurowane nowe akcje. 
## Workflow 1 – build przy push do gałęzi 

<img width="750" height="455" alt="image" src="https://github.com/user-attachments/assets/2c7cf5ec-7ccd-4dbc-87b7-2765b1104e79" />

Utworzono pierwszy potok CI. Jego działanie opiera się na trzech głównych założeniach: 
• Wyzwalacz (Trigger): Akcja jest uruchamiana w momencie wystąpienia 
zdarzenia push wyłącznie dla gałęzi ino_dev. 
• Zadania: Środowisko bazuje na najnowszym systemie Ubuntu (ubuntu-latest). Po 
pobraniu kodu, wywoływane jest polecenie make, które buduje projekt z kodów 
źródłowych. 
• Artefakt: Dodano krok wykorzystujący akcję actions/upload-artifact@v4.  
## Workflow 2 – własne kryterium 

<img width="747" height="344" alt="image" src="https://github.com/user-attachments/assets/d1fbe5ca-7c3e-47bf-85a8-30afaa5fc924" />


Utworzono drugi, niezależny potok realizujący podejście Shift-left. 
• Wyzwalacz (Trigger): W tym przypadku wyzwalaczem jest 
zdarzenie pull_request kierowane do gałęzi ino_dev. 
• Zadania: Potok odpowiada za analizę kodu C. W pierwszej kolejności środowisko 
instaluje narzędzie cppcheck, a następnie uruchamia statyczną analizę kodu załączając 
odpowiednie flagi weryfikujące błędy i ostrzeżenia (--enable=warning,style --error
exitcode=0). 
## Ustawienie repozytorium: 

<img width="737" height="272" alt="image" src="https://github.com/user-attachments/assets/a6553101-a0df-4605-9e50-3147cef6c10e" />


Za pomocą narzędzia GitHub CLI przypisano sforkowane repozytorium jako domyślne dla 
bieżącego katalogu. Było to konieczne, ponieważ GitHub CLI automatycznie łączył się z 
oryginalnym repozytorium. 
## Test: 

<img width="706" height="250" alt="image" src="https://github.com/user-attachments/assets/c4ff8c79-e6c6-4933-9bf7-86c701316932" />


Nowo utworzone pliki konfiguracyjne potoków zostały dodane do poczekalni, zacommitowane 
oraz wypchnięte (push) na zdalną gałąź ino_dev. To zdarzenie powinno automatycznie wyzwolić 
Workflow 1. 
## Weryfikacja: 

<img width="745" height="61" alt="image" src="https://github.com/user-attachments/assets/1af046ab-4d38-4c21-824e-ef37261a6fb2" />


Sprawdzono status wykonania akcji. Tabela potwierdza, że potok "Build" został poprawnie 
uruchomiony po zdarzeniu push i zakończył się sukcesem (zielony znacznik). 


<img width="724" height="339" alt="image" src="https://github.com/user-attachments/assets/ef4a6251-219d-46d0-8311-093e10222fdf" />

Pomyślnie zweryfikowano logi z wykonania potoku. Pokazują one bezbłędne przypisanie 
środowiska uruchomieniowego, wykonanie polecenia make i zarchiwizowanie artefaktu. 
## Sprawdzenie artefaktu: 

<img width="738" height="171" alt="image" src="https://github.com/user-attachments/assets/e7168095-3a5f-4527-b1d3-0aba8408adf5" />


Aby udowodnić poprawne wygenerowanie artefaktu, pobrano go za pomocą komendy gh run 
download z odpowiednim identyfikatorem. Polecenie ls potwierdza obecność pobranego 
katalogu ze skompilowanym plikiem binarnym edytora Kilo. 
## Przetestowanie workflow 2: 

<img width="721" height="64" alt="image" src="https://github.com/user-attachments/assets/316097a8-1a46-45ea-b6a5-53143bbf3d41" />


Aby przetestować potok weryfikujący jakość kodu przed włączeniem go do głównej gałęzi, 
utworzono gałąź eksperymentalną ino_dev-test i wprowadzono w niej celową zmianę w kodzie 
źródłowym. 

<img width="734" height="198" alt="image" src="https://github.com/user-attachments/assets/4ba25070-4d4f-4496-b772-3a1fb9378573" />



<img width="748" height="58" alt="image" src="https://github.com/user-attachments/assets/f63e32bd-526b-4286-a5ee-dfb895e21804" />


## Weryfikacja: 

<img width="745" height="58" alt="image" src="https://github.com/user-attachments/assets/7683c4d0-5f2d-4454-9aaf-12799ec25fa0" />

Natychmiast po otwarciu PR sprawdzono listę akcji. Widoczny jest uruchomiony potok "Code 
Quality", wynikający ze zdarzenia pull_request, który w tym momencie był w trakcie 
analizowania kodu (status *). 

<img width="742" height="45" alt="image" src="https://github.com/user-attachments/assets/8418f78e-c13a-4ccd-b364-893a25a9126c" />


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
