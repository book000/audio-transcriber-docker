FROM node:26-slim

ARG CHROME_VERSION=157.0.8103.78-1
ARG CHROME_SHA256=4d740636b5c96f687798602c5aad6a5a270f44dd02e48db0638ae77aa4867b1b

RUN apt-get -qq update && apt-get install -y pulseaudio fonts-ipafont
RUN apt-get install -y fonts-liberation libasound2t64 libnspr4 libnss3 libxss1 lsb-release xdg-utils
RUN apt-get install -y wget
RUN wget -q "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb" \
    && echo "${CHROME_SHA256}  google-chrome-stable_${CHROME_VERSION}_amd64.deb" | sha256sum -c -
RUN apt install -y ./google-chrome*.deb

RUN groupadd -r user && useradd -r -g user user

RUN sed -i 's/load-module module-console-kit/# load-module module-console-kit/g' /etc/pulse/default.pa

RUN mkdir -p /opt/bin
COPY package.json package-lock.json /opt/bin/
RUN cd /opt/bin && PUPPETEER_SKIP_DOWNLOAD=true npm ci --omit=dev

RUN chmod 777 -R /opt/
RUN mkdir /home/user/
RUN chown -R user:user /home/user/
RUN chown -R user:user /opt/

USER user

RUN mkdir -p /opt/media
COPY audio.wav /opt/media/audio.wav
COPY user-dir/ /opt/user-dir/

COPY main.js /opt/bin/
COPY --chmod=755 entrypoint.sh /opt/bin/

USER root
RUN chown -R user:user /opt/ && chmod -R a+rwX /opt/

USER user

ENTRYPOINT /opt/bin/entrypoint.sh