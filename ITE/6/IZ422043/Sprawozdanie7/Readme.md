# Sprawozdanie – Jenkinsfile: lista kontrolna

# 1. Pipeline jako kod (SCM)

Definicja pipeline została przeniesiona do repozytorium jako `Jenkinsfile`.

Dzięki temu:
- pipeline nie jest definiowany w UI Jenkins,
- definicja jest wersjonowana razem z kodem,
- każda zmiana pipeline jest śledzona w Git.

---

# 2. Aktualność kodu (clone / checkout)

Pipeline zawsze pobiera aktualną wersję kodu z repozytorium przy każdym uruchomieniu.

Oznacza to:
- brak cache lokalnego Jenkins,
- każdorazowe wykonanie `checkout SCM`,
- gwarancję pracy na najnowszym commitcie.

---

# 3. Etap BUILD

Etap `build` używa plików Dockerfile.build z repozytorium i tworzy obraz buildowy

---

# 4. Etap TEST

Etap `test` używa plików Dockerfile.test z repozytorium i przeprowadza testy na artefakcie etapu BUILD

---

# 4. Etap DEPLOY

Etap `deploy` używa artefaktu etapu BUILD i uruchamia aplikację w kontenerze
