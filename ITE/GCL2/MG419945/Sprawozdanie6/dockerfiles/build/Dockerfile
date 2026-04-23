FROM ubuntu:24.04

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y --no-install-recommends ca-certificates ninja-build gettext cmake curl build-essential git

RUN useradd -ms /bin/bash jenkins

WORKDIR /code
RUN chown -R jenkins:jenkins /code
RUN chmod 755 /code
RUN git clone https://github.com/glamac/neovim

WORKDIR /code/neovim
USER jenkins

ENV CMAKE_BUILD_TYPE=RelWithDebInfo
RUN make
