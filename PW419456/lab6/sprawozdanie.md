# Sprawozdanie - Laboratorium 6: Pipeline CI/CD dla Libsodium
**Piotr Walczak 419456**

- [Dockerfile.ci](./Dockerfile.ci) - Multi-stage Build. Plik realizuje budowanie wieloetapowe.
- [Jenkinsfile](./Jenkinsfile) - Definicja potoku CI/CD.

## 1. Realizacja Ścieżki Krytycznej i Checklisty

### Etap: Build i Konteneryzacja
W celu realizacji punktów dotyczących izolacji, stworzono plik `Dockerfile.ci` o strukturze wieloetapowej.
* **Kompilacja wewnątrz kontenera:** Cały proces kompilacji odbywa się w etapie `builder`.
* **Wybór kontenera bazowego:** Wykorzystano `ubuntu:22.04` jako stabilne środowisko z kompletem narzędzi `build-essential`.
* **Uzasadnienie (Checklista):** Kontener budujący zawiera pełen zestaw narzędzi kompilacyjnych, co czyni go dużym i mniej bezpiecznym. Do fazy **Deploy** tworzymy nowy, czysty obraz, kopiując tylko gotowe biblioteki `.so`.

