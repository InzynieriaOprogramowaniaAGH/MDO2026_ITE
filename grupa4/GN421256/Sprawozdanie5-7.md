# Sprawozdanie zbiorcze 5–7 (Jenkins + CI/CD)

Dokument zbiera najważniejsze informacje ze sprawozdań:
- `Sprawozdanie5/README.md`
- `Sprawozdanie6/README.md`
- `Sprawozdanie7/README.md`

Repozytorium wykorzystywane w pipeline:
- `REPO_URL`: `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- `BRANCH`: `GN421256`

Budowany projekt (w kontenerze buildowym) to repo `axios/axios` (klonowane w `Dockerfile.build`).

---

## Sprawozdanie 5 (10.04.2026) –  Jenkins + pierwszy pipeline

### Uruchomienie Jenkinsa i zadania przykładowe
Wykonano uruchomienie środowiska Jenkins oraz trzy przykładowe zadania:
- `uname`
- sprawdzanie warunku (np. godzina parzysta/nieparzysta)
- uruchomienie Dockera w Jenkinsie

Dowody: zrzuty w `Sprawozdanie5/` (m.in. `dockerjenkins.png`, `1-uname.png`, `2-odd.png`, `3-docker.png`).

### Pierwszy pipeline (Checkout + Build)
Pipeline realizował:
- `Checkout` (clone z SCM)
- `Build Dockerfile` (budowa obrazu z `Dockerfile.build`)

Fragment (z `Sprawozdanie5/README.md`):
- `DOCKERFILE_PATH = 'grupa4/GN421256/Sprawozdanie3/Dockerfile.build'`
- `IMAGE_TAG = "builder:${BUILD_NUMBER}"`

Pipeline był uruchomiony więcej niż raz (screen „Uruchomienie 2 razy”).

Wniosek: była to wersja minimalna (bez `test/deploy/publish`).

---

## Sprawozdanie 6 (17.04.2026) – ścieżka krytyczna CI/CD

Wersja pipeline została rozszerzona do ścieżki krytycznej:
1. **Manual Trigger**
2. **Clone**
3. **Build**
4. **Test**
5. **Deploy (smoke)**
6. **Publish**

### Build
Budowany był obraz na bazie `Dockerfile.build`:
- `docker build -f "$DOCKERFILE_BUILD" -t "$BUILD_IMAGE" .`

### Test
Testy uruchamiane były w kontenerze (z obrazu buildowego).
Ze względu na niestabilność części testów w danym środowisku, wykluczono:
- `tests/unit/adapters/fetch.test.js`

Przykład:
- `npx vitest run --project unit --exclude tests/unit/adapters/fetch.test.js`

Uzasadnienie: bez wykluczenia pipeline nie przechodziłby dalej (błąd środowiskowy / `Network Error` zamiast oczekiwanego `timeout`).

### Deploy (smoke)
Smoke test polegał na weryfikacji, że rezultat budowy istnieje (folder `dist`):
- `test -d dist && ls -la dist | head -n 50`

### Publish
Artefakt był publikowany jako `.tar` w historii buildu:
- `docker save "$BUILD_IMAGE" -o "$ARTIFACT_TAR"`
- `archiveArtifacts ... fingerprint: true`

Dowód: `Sprawozdanie6/1-success.png`.

---

## Sprawozdanie 7 – Jenkinsfile „as code” + osobne role obrazów (BLDR/TEST/DEPLOY)

Cel zgodny z checklistą z `READMEs/07-Class.md`:
- pipeline ma być pobierany z repo (**Pipeline from SCM**),
- ma sprzątać po sobie (`cleanWs()`),
- ma być powtarzalny (działa > 1 raz),
- „na końcu rurociągu” powstaje **deployable** artefakt.

### Pliki w repo (obok sprawozdania)
W `Sprawozdanie7/` znajdują się:
- `Jenkinsfile`
- `Dockerfile.build` (BLDR)
- `Dockerfile.test` (TEST, oparty o BLDR)
- `Dockerfile.deploy` (DEPLOY, osobny obraz docelowy)

### Rozdzielenie ról obrazów
- **BLDR**: buduje projekt (zależności, build, `dist/`)
- **TEST**: bazuje na BLDR i uruchamia testy (z wykluczeniem `fetch.test.js`)
- **DEPLOY**: obraz docelowy (lżejszy), zawiera tylko `dist/` + minimalne metadane

### Brak pracy na cache
W buildach obrazów użyto `--no-cache` (żeby ograniczyć wpływ cache Dockera i mieć większą pewność, że pipeline operuje na świeżym stanie).

### Deploy + smoke test
Wdrożenie to uruchomienie kontenera obrazu docelowego, a smoke test sprawdza obecność `dist/` w obrazie deploy.

### Publish + identyfikacja pochodzenia artefaktu
Artefakty publikowane do historii buildu:
- `axios-deploy-image-<version>-<gitsha>.tar`
- `build-info.txt` (branch, git sha, build number, version)

Wersjonowanie: `0.7.<BUILD_NUMBER>` + skrócony `git_sha` w tagu/artefakcie.

### Definition of done (deployable)
Po pobraniu artefaktu `.tar` można go uruchomić bez modyfikacji:

```bash
docker load -i axios-deploy-image-<version>-<gitsha>.tar
docker run --rm axios-deploy:<version>-<gitsha>
```

---

## Podsumowanie zmian 5 → 6 → 7
- **Sprawozdanie 5**: start Jenkinsa + pierwszy pipeline (checkout + build).
- **Sprawozdanie 6**: pełna ścieżka krytyczna (test/smoke/publish).
- **Sprawozdanie 7**: pipeline przeniesiony do repo (SCM), sprzątanie, powtarzalność, rozdzielenie BLDR/TEST/DEPLOY, wersjonowanie i metadane pochodzenia artefaktu.

