FROM docker.io/kalilinux/kali-rolling:latest

LABEL org.label-schema.name='OMINO - Kali Linux' \
    org.label-schema.description='Automated pentest framework for offensive security experts' \
    org.label-schema.usage='https://github.com/Athexblackhat/OMINO' \
    org.label-schema.url='https://github.com/Athexblackhat/OMINO' \
    org.label-schema.schema-version='1.0' \
    org.label-schema.docker.cmd.devel='docker run --rm -ti ATHEX BLACK HAT/omino' \
    MAINTAINER="@Athexblackhat"

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive

RUN set -x \
        && apt -yqq update \
        && apt -yqq full-upgrade \
        && apt clean
RUN apt install --yes metasploit-framework

RUN sed -i 's/systemctl status ${PG_SERVICE}/service ${PG_SERVICE} status/g' /usr/bin/msfdb && \
    service postgresql start && \
    msfdb reinit

WORKDIR /usr/src/app

RUN apt --yes install git bash
RUN git clone https://github.com/Athexblackhat/OMINO.git \
    && cd omino \
    && ./install.sh \
    && omino -u force

CMD ["omino"]