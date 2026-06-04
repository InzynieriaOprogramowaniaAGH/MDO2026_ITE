Autor: Maciej Fraś 

Data: 4 Czerwca 2026 r.

Środowisko: Ubuntu 24.04.4 LTS (Virtual Machine / Hyper-V), Visual Studio Code (VSC)

1. Cel zajęć
Wdrażanie na zarządzalne kontenery: Kubernetes (Strategie i Rollout)

2. Przygotowanie obrazów aplikacji DOcker Hub
W Docker Hub przygotowano trzy niezależne wersje obrazów oparte na dystrybucji nginx:alpine.

![setDockerLogin](ss/setDockerLogin.png)

Następnie zbudowano i przesłano wymagane wersje oprogramowania:

Starsza wersja serwera aplikacji.

![buildOldVersion](ss/buildOldVersion.png)
![pushOldVersion](ss/pushOldVers.png)

Nowa wersja zawierająca zmodyfikowany plik statyczny

![buildNewVersion](ss/buildNewVersion.png)
![pushNewVersion](ss/pushNewVers.png)

Wersja broken - uzszkodzony punkt wejścia (CMD), wymuszający awarię kontenera przy starcie

![errorVersion](ss/errorVersion.png)

3. Skalowanie oraz zarządzanie historią wdrożeń (Rollout)
Dynamiczne skalowania wielkości klastra za pomocą mechanizmu kubectl scale.

![getPods](ss/getPods.png)

Przetestowanie mechanizmu aktualizacji oprogramowania w locie oraz kontroli awarii - Rollout. Po wdrożeniu obrazu :broken, pody weszły w stan awaryjny. Stan wdrożenia zweryfikowano poleceniem:

![rollout](ss/rollout.png)

W celu natychmiastowego przywrócenia sprawności operacyjnej środowiska, uzyto komendy, która cofnęła ostatnie zmiany (rollout undo), która automatycznie wygasiła uszkodzone pody i ustawiła stabilną wersję oprogramowania.

![deployBroken](ss/deployBroken.png)

Stan przejściowy klastra – widoczna koegzystencja podów ze stanem błędu CrashLoopBackOff oraz nowo generowanych zdrowych instancji

![rollout-undo](ss/rollout-undo.png)

4. Implementacja skryptu weryfikacyjnego (Kontrola wdrożenia)