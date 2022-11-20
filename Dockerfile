FROM node:19-slim

RUN apt-get -qq update && apt-get install -y pulseaudio fonts-ipafont
RUN yarn add puppeteer

RUN apt-get install -y libappindicator1 fonts-liberation libasound2 libnspr4 libnss3 libxss1 lsb-release xdg-utils
RUN apt-get install -y wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome*.deb

RUN groupadd -r user && useradd -r -g user user

RUN sed -i 's/load-module module-console-kit/# load-module module-console-kit/g' /etc/pulse/default.pa

RUN chmod 777 -R /opt/
RUN mkdir /home/user/
RUN chown -R user:user /home/user/
RUN chown -R user:user /opt/

USER user

RUN mkdir -p /opt/media
COPY audio.wav /opt/media/audio.wav
COPY user-dir/ /opt/user-dir/

COPY main.js /opt/bin/
COPY entrypoint.sh /opt/bin/

USER root
RUN chown -R user:user /opt/

USER user

ENTRYPOINT /opt/bin/entrypoint.sh