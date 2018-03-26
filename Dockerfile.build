FROM debian:stretch

RUN apt-get update\
    && apt-get install -y automake git build-essential libcurl4-openssl-dev zlib1g-dev\
    && apt-get install -y emacs25-nox git w3m \
    && rm -rf /var/lib/apt/lists/*

# --- install roswell --- #

RUN git clone --depth=1 -b release https://github.com/roswell/roswell.git && \
    cd roswell && \
    sh bootstrap && \
    ./configure --disable-manual-install && \
    make && \
    make install && \
    cd .. && \
    rm -rf roswell

