# Zajęcia 06
---

## Pipeline: lista kontrolna
Scharakteryzuj plan na *pipeline* i przedstaw postęp prac. Czy mamy pomysł na każdy krok poniżej?

### Ścieżka krytyczna
Podstawowy zbiór czynności do wykonania w ramach zadania z pipelinem CI/CD. Ścieżką krytyczną jest:
- [X] commit (lub tzw. *manual trigger* @ Jenkins)
- [X] clone
- [X] build
- [X] test
- [X] deploy
- [X] publish

Poniższe czynności wykraczają ponad tę ścieżkę, ale zrealizowanie ich pozwala stworzyć pełny, udokumentowany, jednoznaczny i łatwy do utrzymania pipeline z niskim progiem wejścia dla nowych *maintainerów*.

### Pełna lista kontrolna
Zweryfikuj dotychczasową postać sprawozdania oraz planowane czynności względem ścieżki krytycznej oraz poniższej listy. Realizacja punktu wymaga opisania czynności,
wykazania skuteczności (np. zrzut ekranu), podania poleceń i uzasadnienia decyzji dot. implementacji.

- [X] Aplikacja została wybrana
- [X] Licencja potwierdza możliwość swobodnego obrotu kodem na potrzeby zadania
- [X] Wybrany program buduje się
- [X] Przechodzą dołączone do niego testy
- [X] Zdecydowano, czy jest potrzebny fork własnej kopii repozytorium
- [X] Stworzono diagram UML zawierający planowany pomysł na proces CI/CD
- [X] Wybrano kontener bazowy lub stworzono odpowiedni kontener wstepny (runtime dependencies)
- [X] *Build* został wykonany wewnątrz kontenera
- [X] Testy zostały wykonane wewnątrz kontenera (kolejnego)
- [X] Kontener testowy jest oparty o kontener build
- [X] Logi z procesu są odkładane jako numerowany artefakt, niekoniecznie jawnie
- [X] Zdefiniowano kontener typu 'deploy' pełniący rolę kontenera, w którym zostanie uruchomiona aplikacja (niekoniecznie docelowo - może być tylko integracyjnie)
- [X] Uzasadniono czy kontener buildowy nadaje się do tej roli/opisano proces stworzenia nowego, specjalnie do tego przeznaczenia
- [X] Wersjonowany kontener 'deploy' ze zbudowaną aplikacją jest wdrażany na instancję Dockera
- [X] Następuje weryfikacja, że aplikacja pracuje poprawnie (*smoke test*) poprzez uruchomienie kontenera 'deploy'
- [X] Zdefiniowano, jaki element ma być publikowany jako artefakt
- [X] Uzasadniono wybór: kontener z programem, plik binarny, flatpak, archiwum tar.gz, pakiet RPM/DEB
- [X] Opisano proces wersjonowania artefaktu (można użyć *semantic versioning*)
- [X] Dostępność artefaktu: publikacja do Rejestru online, artefakt załączony jako rezXltat builda w Jenkinsie
- [X] Przedstawiono sposób na zidentyfikowanie pochodzenia artefaktu
- [X] Pliki Dockerfile i Jenkinsfile dostępne w sprawozdaniu w kopiowalnej postaci oraz obok sprawozdania, jako osobne pliki
- [X] Zweryfikowano potencjalną rozbieżność między zaplanowanym UML a otrzymanym efektem