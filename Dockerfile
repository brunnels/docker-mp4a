FROM jfloff/alpine-python:3.4
MAINTAINER Benjamin Runnels <kraven@kraven.org

ENV SOFTWARE_VERSION=3.3.5
ENV SOFTWARE_VERSION_URL=http://ffmpeg.org/releases/ffmpeg-${SOFTWARE_VERSION}.tar.bz2
ENV BIN=/usr/bin

WORKDIR /tmp/ffmpeg

RUN cd && \
apk update && \
apk upgrade && \
apk --no-cache add \
  git \
  freetype-dev \
  gnutls-dev \
  lame-dev \
  libass-dev \
  libogg-dev \
  libtheora-dev \
  libvorbis-dev \
  libvpx-dev \
  libwebp-dev \
  libssh2 \
  opus-dev \
  rtmpdump-dev \
  x264-dev \
  x265-dev \
  yasm-dev \
  libffi-dev && \
apk add --no-cache   --virtual \
  .build-dependencies \
  build-base \
  bzip2 \
  coreutils \
  gnutls \
  nasm \
  tar \
  x264 && \
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
apk add --update --no-cache fdk-aac-dev && \
echo "http://dl-cdn.alpinelinux.org/alpine/v3.4/main/" > /etc/apk/repositories && \
DIR=$(mktemp -d) && \
cd ${DIR} && \
wget ${SOFTWARE_VERSION_URL} && \
tar xjvf ffmpeg-${SOFTWARE_VERSION}.tar.bz2  && \
cd ffmpeg* && \
PATH="$BIN:$PATH" && \
./configure \
    --disable-ffplay \
    --enable-avresample \
    --enable-gnutls \
    --enable-gpl \
    --enable-libass \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-librtmp \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-postproc \
    --enable-small \
    --enable-version3 \
    --enable-libfdk-aac \
    --enable-openssl \
    --enable-runtime-cpudetect \
    --disable-debug && \
make -j20 && \
make -j20 install && \
make -j20 distclean && \
rm -rf ${DIR}  && \
apk del --purge   .build-dependencies && \
rm -rf /var/cache/apk/*

WORKDIR /usr/share
RUN git clone git://github.com/mdhiggins/sickbeard_mp4_automator.git mp4_automator && \
wget https://bootstrap.pypa.io/ez_setup.py -O - | python && \
rm -rf setuptools-33.1.1.zip && \
pip install requests && \
pip install requests-cache && \
pip install babelfish && \
pip install "guessit<2" && \
pip install stevedore==1.19.1 && \
pip install "subliminal<2" && \
pip install deluge-client && \
pip install qtfaststart && \
pip install requests[security]

COPY autoProcess.ini /usr/share/mp4_automator/autoProcess.ini

CMD ["/bin/bash"]

#ENTRYPOINT ["/usr/local/mp4_automator/manual.py"]




#  apt-get install ffmpeg git python-pip python-dev libfdk-aac-dev -y
#  pip install --upgrade pip
#  pip install requests requests[security] requests-cache babelfish 'guessit<2' 'subliminal<2' stevedore==1.19.1 python-dateutil qtfaststart
#  git clone git://github.com/mdhiggins/sickbeard_mp4_automator.git /config/sickbeard_mp4_automator/
#  touch /config/sickbeard_mp4_automator/info.log
#  chmod a+rwx -R /config/sickbeard_mp4_automator
#  ln -s /downloads /data
#  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# https://github.com/milleruk/docker-sonarr-mp4/blob/master/Dockerfile


#WORKDIR /work

### MP4 Automator
#RUN git clone git://github.com/mdhiggins/sickbeard_mp4_automator.git mp4_automator
#COPY autoProcess.ini /work/mp4_automator/autoProcess.ini

## Install Configs
#RUN mkdir -p /var/log/supervisor
#COPY supervisord.conf /work/supervisord.conf

VOLUME ["/config", "/storage", "/incoming"]

#CMD [ "-c", "/work/supervisord.conf"]
#ENTRYPOINT ["/usr/bin/supervisord"]