# Jenkinsfile

Utworzono fork repozytorium FLAC (https://github.com/Garnn/flac) aby dodać do niego następnie Jenkinsfile aby móc pobierać pipeline prosto z SCM.

# Kroki Jenkinsfile

1. Przepis jest w pełni dostarczany z SCM oraz kompilacja wykonuje się zawsze na najświeższym kodzie.

2. Jenkinsfile zawiera również schemat przygotowywania obrazów do budowania i testowania programu.

3. Etap Deploy w rzeczywistości jest obrazem builder który próbuje przeprowadzić instalację jako root i przetestować czy działa narzędzie CLI. (etap Build przygotowuje już wszystkie potrzebne artefakty, więc deploy nic nie musi przygotowywać poza sprawdzeniem czy działają)

4. Etap publish zbiera gotowe artefakty i załącza je jako wynik builda.

5. Pipeline rzeczywiście wykonuje się poprawnie wiele razy.

# Definition of done
Pobrano bibliotekę na hosta maszyny wirtualnej, po zainstalowaniu do folderu /lib pobrane narzędzie CLI również poprawnie działa.