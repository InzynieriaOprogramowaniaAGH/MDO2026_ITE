# Sprawozdanie 4

Sprawozdanie dla [ćwiczenia trzeciego][ex3].

## Cel ćwiczenia

Rozszerzenie umiejętności konteneryzacji o współdzielenie danych przez m.in.
mechanizm woluminów. Zarządzanie i badanie stosu sieciowego kontenerów.
Instalacja Jenkins CI w Docker.

## Sprzęt

Wykorzystano jednostkę fizyczną z zainstalowanym systemem Linux.

## Przebieg ćwiczenia

> [!NOTE]
> Przyjąłem, że jest to kontynuacja ćwiczenia 4. Będę więc wykorzystywać
> dalej oprogramowanie [`pacman`], chyba że charakter ćwiczenia
> z jakiejkolwiek przyczyny mi na to nie pozwoli (co jest wątpliwe).

### 1. Klonowanie repozytorium, przygotowanie woluminów

Dla Dockera w trybie rootless, oczywistym jest, że woluminy nie są położone
w `/var/lib/docker`, jak wskazano w instrukcji, jako że ten katalog jest
zwykle przeznaczony dla plików usług systemowych i dostępne są, prócz
konta `root`, co najwyżej przez wytyczone konta usług, jeżeli takowe
w ogóle są tworzone dla danej usługi (jest to dobra praktyka z uwagi
na niebezpieczeństwa konta `root`, lecz niezawsze domyślnie stosowana).

Stwarzam więc wymagane dla realizacji zadania woluminy i sprawdzam
właściwości pierwszego, aby wykazać użytą ścieżkę:

![Okno terminala 1](anim/01-docker-vols.gif)

Cenzurę dla dokładnej lokalizacji zastosowałem tutaj celowo, przypominam
że prace są dostępne publiczne a ja nie zamierzam udostępniać potencjalnym
wektorom ataku choćby skrawka mojej konfiguracji systemu.

> [!TIP]
> Rozwiązywanie ścieżki Dockera udało mi się zdefiniować przez funkcję:
> ```sh
> volume() {
>   echo "${XDG_CONFIG_DATA:-$HOME/.local/share}/docker/volumes/$1/_data/$2"
> }
> ```
> Funkcję wykorzystać można jako *de-facto* dynamiczną zmienną, przykładowo:
> ```console
> $ ls "$(volume volin /)"
> ```
> Pozwala na odniesienie się relatywnie do ścieżki `/` w woluminie
> `volin`: w tym sensie `/` nie odnosi się do ścieżki `/` systemowej,
> a do katalogu `_data`, czyli korzenia samego voluminu.
>
> Dodatkowo, dla `XDG_CONFIG_DATA=/var/lib`, osiągamy kompatybilność
> dla tradycyjnej instalacji Dockera z uprawnieniami `root`.

Ponawiam dalej krok przygotowawczy poza repozytorium dla sklonowania repo
względem określonego tagu (interesuje mnie budowa wydania stabilnego),
będąc w właściwej ścieżce dla voluminu `volin`:

![Okno terminala 2](anim/02-git-clone.gif)

Klonuje tym samym repo bezpośrednio na punkt montowania woluminu na hoście.
Robię to w ten sposób, aby ograniczyć potrzebę kopiowania danych na wolumin
wyjściowy, które z uwagi na metadane folderu `.git` jest nie tylko dość zbędnym
procesem dla nas, ale i kosztownym czasowo. W CI/CD pipeline też dla przypadku
kopiowania repo, nawet lokalnie, często stosuje się nie `cp` a `git clone`,
jako że pozwala to na uzyskanie czystego drzewa repozytorium, niezależnie od stanu
drzewa, z którego dokonywane jest klonowanie. `.git` lokalnie potrafi też tworzyć
twarde linki, co jest użyteczne dla danych trzymanych na tym samym rzeczywistym
systemie plików i pozwala na deduplikację. *Bind mount* jest za to bardzo dobrą
alternatywą dla uzyskania dostępu bezpośrednio przez katalog hosta, choć czasami
lepszą i bezpieczniejszą opcją być może zrzucenie repo (nawet istniejące lokalnie)
do odrębnej przestrzenii dla uzyskania efektu sandboxingu. Wolumin dodatkowo
dla kolejnych kroków CI/CD pozwala na uzyskanie pamięci stanu, co tworzy separację
kontenerową dla pipeline, a jednocześnie pozwala na zapamiętanie stanu budowy
i wdrażania.  Woluminy są też lepiej zintegrowane z samym ekosystemem

Kontynuując więc dalszą budowę przy zamontowanych woluminach w środowisku kontenera,
przy instalacji dodatkowych zależności:

![Okno terminala 3](anim/03-docker-run.gif)

Flagę `--rm` dodałem, aby usunąć kontener tuż po wyjściu. Dane gotowe do
spakowania w tarball dostępne są w woluminie `volout`:

![Okno terminala 4](anim/04-ls-volout.gif)

Ponawiam więc budowę, tym razem klonując wewnątrz kontenera:

![Okno terminala 5](anim/05-redo-build.gif)

Możliwe jest też wykorzystanie plików Dockerfile do zarządzania i populacji
woluminów (można wykorzystać `RUN --mount` do montowania, ale i również operować
bez montarzu woluminów, a jedynie definiować, jakimi danymi wolumin ma być
populowany, wykorzystując `VOLUME`). Pierwsza opcja może uprościć budowę obrazu przez
wykorzystanie istniejących danych, inne opcje montażu pozwalają również na takie
czynności, jak bezpieczne udostępnianie kontenerowi kluczy (np. do API lub SSH) czy,
mówiąc o innym już przypadku, przyspieszanie budowy czy ciągłej integracji przez
montaż *cache*. Drugi przypadek ma sens, gdy chcemy współdzielić stan lub mieć opcję
zrzutu informacji poza kontener.

### 2. IPerf: badanie sieci w Docker

Dla realizacji tej części zadania, posłużę się obrazem dedykowanym dla `iperf`:

![Okno terminala 6](anim/06-pull-iperf3.gif)

Ustawiam kontenery równolegle na tej samej sieci:

<table><tr><td>

![Okno terminala 7: zakładka serwer](anim/07-iperf3-server.gif)

</td><td>

![Okno terminala 7: zakładka klient](anim/07-iperf3-client.gif)

</td></tr></table>

W kolejnym kroku tworzę odrębną sieć:

![Okno terminala 6](anim/08-my-net.gif)

…i powtarzam badanie, tym razem w dedykowanej sieci i przez użycie nazw kontenerów
zamiast adresacji:

Ustawiam kontenery równolegle na tej samej sieci:

<table><tr><td>

![Okno terminala 9: zakładka serwer](anim/09-net-iperf3-server.gif)

</td><td>

![Okno terminala 9: zakładka klient](anim/09-net-iperf3-client.gif)

</td></tr></table>

### 3. Środowisko CI/CD Jenkins

Podążając za instrukcją, instaluję Jenkins w środowisku skonteneryzowanym:

![Okno terminala 10](anim/10-jenkins.gif)

Pominąłem dostrajanie obrazu o własne dodatki i bezpośrednio wykorzystałem
oficjalny obraz dla obecnej instalacji. Zainicjalizowałem instalację dalej
graficznie, w przeglądarce:

![Okno przeglądarki](video/jenkins.mp4)

<!-- Linki: --->
[ex3]: ../../../../READMEs/03-Class.md "Dockerfiles, kontener jako definicja etapu"
[`pacman`]: https://www.archlinux.org/pacman/ "Menedżer pakietów systemu Arch Linux"
[`main/Dockerfile`]: docker/main/Dockerfile
[`test/Dockerfile`]: docker/test/Dockerfile
