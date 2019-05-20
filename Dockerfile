FROM alpine:latest

RUN ARCHITECTURE=linux_x64                                                                    && \
    SHA256_DUPLICACY=3f950e8f60e16b8afbac6f67d7c6651019b8e24e22e1b38f7f5c80d4e36022dc         && \
    SHA256_DUPLICACY_WEB=ccf2136014a3b751e52fe503eaa47785794c6ea77d33718d83b0457907862b04     && \
    VERSION_DUPLICACY=2.2.0                                                                   && \
    VERSION_DUPLICACY_WEB=1.0.0                                                              && \
                                                                                                 \
    # ------------------------------------------------------------------------------------------
                                                                                                 \
    _URL_DUPLICACY="$(                                                                           \
      printf https://github.com/gilbertchen/duplicacy/releases/download/v%s/duplicacy_%s_%s      \
      $VERSION_DUPLICACY $ARCHITECTURE $VERSION_DUPLICACY                                        \
    )"                                                                                        && \
    _URL_DUPLICACY_WEB="$(                                                                       \
      printf https://acrosync.com/duplicacy-web/duplicacy_web_%s_%s                              \
      $ARCHITECTURE $VERSION_DUPLICACY_WEB                                                       \
    )"                                                                                        && \
    _BIN_DUPLICACY=/usr/local/bin/duplicacy                                                   && \
    _BIN_DUPLICACY_WEB=/usr/local/bin/duplicacy_web                                           && \
    _DIR_WEB=~/.duplicacy-web                                                                 && \
    _DIR_CONF=/etc/duplicacy                                                                  && \
    _DIR_CACHE=/var/cache/duplicacy                                                           && \
                                                                                                 \
    # add ca-certificates so Duplicacy doesn't complain
    apk update                                                                                && \
    apk add --no-cache ca-certificates                                                        && \
                                                                                                 \
    # download, check, and install duplicacy
    wget -O $_BIN_DUPLICACY "$_URL_DUPLICACY"                                                 && \
    echo "${SHA256_DUPLICACY}  ${_BIN_DUPLICACY}" | sha256sum -s -c -                         && \
    chmod +x $_BIN_DUPLICACY                                                                  && \
                                                                                                 \
    # downlooad, check, and install the web UI
    wget -O $_BIN_DUPLICACY_WEB "$_URL_DUPLICACY_WEB"                                         && \
    echo "${SHA256_DUPLICACY_WEB}  ${_BIN_DUPLICACY_WEB}" | sha256sum -s -c -                 && \
    chmod +x $_BIN_DUPLICACY_WEB                                                              && \
                                                                                                 \
    # create some dirs
    mkdir -p                                                                                     \
      ${_DIR_CACHE}/repositories                                                                 \
      ${_DIR_CACHE}/stats                                                                        \
      ${_DIR_WEB}/bin                                                                            \
      /var/lib/dbus                                                                           && \
                                                                                                 \
    # duplicacy_web expects to find the CLI binary in a certain location
    # https://forum.duplicacy.com/t/run-web-ui-in-a-docker-container/1505/2
    ln -s $_BIN_DUPLICACY ${_DIR_WEB}/bin/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY}      && \
                                                                                                 \
    # redirect the log to stdout
    ln -s /dev/stdout /var/log/duplicacy_web.log                                              && \
                                                                                                 \
    # stage the rest of the web directory
    ln -s ${_DIR_CONF}/settings.json  ${_DIR_WEB}/settings.json                               && \
    ln -s ${_DIR_CONF}/duplicacy.json ${_DIR_WEB}/duplicacy.json                              && \
    ln -s ${_DIR_CONF}/licenses.json  ${_DIR_WEB}/licenses.json                               && \
    ln -s ${_DIR_CONF}/filters        ${_DIR_WEB}/filters                                     && \
    ln -s ${_DIR_CACHE}/stats         ${_DIR_WEB}/stats

EXPOSE 3875
CMD [ "/usr/local/bin/entrypoint.sh" ]

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME ["/var/cache/duplicacy", "/etc/duplicacy"]
