## Sprawozdanie

### Rozpocząłem pobierając minikube i sprawdzając poprawność instalacji

![](1.png)

### Uruchomiłem klaster kubernetes następującym poleceniem, po czy sprawdziłem jego poprawność

minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=2000 \
  --disk-size=4g \
  --insecure-registry="10.0.2.3:5000" \
  --force

![](2.png)

### Umożliwiło to uruchomienie dashboarda, początkowo pustego

![](3.png)

### Przygotowałem prostą aplikację z podanych plików. Umieściłem jej obraz w rejestrze docker oraz uruchomiłem pod.

![](4.png)

![](5.png)

### Utworzyłem deployment i service

![](6.png)

### Uruchomiłem

minikubctl apply -f deployment-mf419850-web.yml
minikubctl rollout status deployment/mf419850-web

### Wdrożenie przebiegło poprawnie

![](7.png)

![](8.png)

![](9.png)