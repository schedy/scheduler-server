FROM fedora/tools

ARG APP=webssh
ARG HOME=/home/$USER

COPY lib/$APP/app $HOME/$APP/

WORKDIR $HOME/$APP/
RUN dnf install -y npm
RUN npm install --production
EXPOSE 2222/tcp
