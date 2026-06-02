# Sprawozdanie 2
Bartłomiej Nosek 
---
### Cel ćwiczenia
Zapoznanie się z dockerem, tworzenie pierwszych obrazów i kontenerów  

### Przebieg laboratoriów
- instalacja dockera `sudo apt install docker.io -y`  
- pobieranie testowych obrazów  
- uruchamianie i budowania kontenerów `docker build -t devops-repo-env .` i `docker run -it devops-repo-env`
- system w kontenerze  
- utworzenie pliku dockerfile  
```console
FROM ubuntu

RUN apt-get update && \
 apt-get install -y git

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
```
  ## Zrzuty ekranu:
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="obrazy.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="kod_wyjscia.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="w_kontenerze.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="ubuntu.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="uspiony.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="z_budowania.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="klon na konenerze.png" />
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="kontenery_aktywne.png" />
