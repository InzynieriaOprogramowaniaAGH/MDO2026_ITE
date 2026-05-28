# Sprawozdanie - zajęcia 11

### Przygotowanie nowego obrazu

1. Przygotowanie dwóch wersji obrazów w katalogu app:
```
app/
 ├── Dockerfile
 └── index.html
```

#### Index.html
```
<h1>Wersja 1</h1>
```
#### Dockerfile
```Dockerfile
FROM httpd:2.4
COPY index.html /usr/local/apache2/htdocs/index.html
```

2. Budowanie:

![1](obrazyLab11/1.png)
![2](obrazyLab11/2.png)

3. Wysłanie do Docker Hub:

![3](obrazyLab11/3.png)
![4](obrazyLab11/4.png)

4. Przygotowanie drugiej wersji (v2) i wersji wadliwej, budowanie, push, uruchomienie:

![5](obrazyLab11/5.png)
![6](obrazyLab11/6.png)
![7](obrazyLab11/7.png)
![8](obrazyLab11/8.png)
![9](obrazyLab11/9.png)

### Zmiany w deploymencie

1. Utworzenie plików deployment.yaml i service.yaml które są umieszczone w folderze `Sprawozdanie11/myapp`.
2. Wdrożenie i sprawdzenie:

![10](obrazyLab11/11.png)
![11](obrazyLab11/12.png)

#### Skalowanie deploymentu

![12](obrazyLab11/13.png)
![13](obrazyLab11/14.png)

#### Dla replic 4 i wiekszej ilości, przywracanie poprzednich wersji, sprawdzenie

![14](obrazyLab11/16.png)
![15](obrazyLab11/17.png)
![16](obrazyLab11/18.png)
![17](obrazyLab11/19.png)
![18](obrazyLab11/20.png)
![19](obrazyLab11/21.png)
![20](obrazyLab11/22.png)
![21](obrazyLab11/23.png)
![22](obrazyLab11/24.png)
![23](obrazyLab11/25.png)
![24](obrazyLab11/26.png)

### Kontrola & Strategie wdrożenia

Skrypt wdrożenia `deploy-check.sh`:
```Bash
(hasztak)!/bin/bash

DEPLOYMENT=myapp-deployment
TIMEOUT=60s

kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT

if [ $? -eq 0 ]; then
    echo "Deployment OK"
    exit 0
else
    echo "Deployment FAILED"
    exit 1
fi
```
![25](obrazyLab11/27.png)
![26](obrazyLab11/28.png)
![27](obrazyLab11/29.png)
![28](obrazyLab11/30.png)
![29](obrazyLab11/31.png)
![30](obrazyLab11/32.png)
![31](obrazyLab11/33.png)

#### Obserwacje:
Recreate:
- szybkie przełączenia
- brak starych podów podczas update
RollingUpdate:
- brak przerwy
- pody wymieniają się stopniowo
- chwilowo więcej podów
Canary:
- równoczesne działanie dwóch wersji

