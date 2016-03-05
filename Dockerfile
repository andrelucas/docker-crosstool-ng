FROM debian:jessie

MAINTAINER André Lucas <andre@ae-35.com>

RUN apt-get -qqy update && DEBIAN_FRONTEND=noninteractive \
  apt-get -qy --no-install-recommends install \
    autoconf \
    automake \
    bison \
    build-essential \
    ca-certificates \
    curl \
    flex \
    gawk \
    git \
    gnupg \
    gperf \
    help2man \
    libtool-bin \
    libncurses5-dev \
    texinfo \ 
    python-dev \
    wget

ENV EXTRACT=/ctng
ENV BUILD=${EXTRACT}/build

RUN useradd -m build
WORKDIR /home/build
COPY bin bin
COPY src src

RUN mkdir -p ${EXTRACT} && chown build:build ${EXTRACT}
RUN mkdir -p ${BUILD} && chown build:build ${BUILD}

USER build
WORKDIR ${EXTRACT}

ENV CTVERS=${CTVERS:-1.22.0}
ENV TGT_ARCH=${TGT_ARCH:-x86_64-unknown-linux-gnu}
ENV TARBALL=crosstool-ng-${CTVERS}.tar.xz
ENV DL=http://crosstool-ng.org/download/crosstool-ng/${TARBALL}

RUN curl -OL ${DL} && \
  curl -OL ${DL}.sig && \
  gpg --keyserver hkp://keys.gnupg.net --recv-key 0x35b871d1 && \
  gpg --verify ${TARBALL}.sig && \
  tar xJf ${TARBALL}

WORKDIR ${EXTRACT}/crosstool-ng
RUN ./configure --prefix=${EXTRACT} && make && make install
ENV PATH=${EXTRACT}/bin:/home/build/bin:${PATH}

WORKDIR ${BUILD}

RUN ct-ng ${TGT_ARCH}
RUN ct-ng source
# Either run the rm -rf .build command, or have a ~8GB layer. Your call.
RUN if test -z "CTNG_NO_BUILD" ; then ct-ng build && rm -rf .build; else exit 0; fi

