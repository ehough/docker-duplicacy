FROM alpine:latest

RUN ARCHITECTURE=linux_x64                                                                    && \
    SHA256_DUPLICACY=034720abb90702cffc4f59ff8c29cda61f14d9065e6ca0e4017ba144372f95d7         && \
    SHA256_DUPLICACY_WEB=322e8865fa5f480952938be018725bf02bd0023a26512eb67216a9f0cb721726     && \
    VERSION_DUPLICACY=2.1.2                                                                   && \
    VERSION_DUPLICACY_WEB=0.2.10                                                              && \
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
    wget --quiet -O $_BIN_DUPLICACY "$_URL_DUPLICACY"                                         && \
    echo "${SHA256_DUPLICACY}  ${_BIN_DUPLICACY}" | sha256sum -s -c -                         && \
    chmod +x $_BIN_DUPLICACY                                                                  && \
                                                                                                 \
    # downlooad, check, and install the web UI
    wget --quiet -O $_BIN_DUPLICACY_WEB "$_URL_DUPLICACY_WEB"                                 && \
    echo "${SHA256_DUPLICACY_WEB}  ${_BIN_DUPLICACY_WEB}" | sha256sum -s -c -                 && \
    chmod +x $_BIN_DUPLICACY_WEB                                                              && \
                                                                                                 \
    # create some dirs
    mkdir -p                                                                                     \
      ${_DIR_CACHE}/repositories                                                                 \
      ${_DIR_CACHE}/stats                                                                        \
      ${_DIR_WEB}/bin                                                                            \
      ${_DIR_CONF}/filters                                                                    && \
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
    ln -s ${_DIR_CONF}/filters        ${_DIR_WEB}/filters                                     && \
    ln -s ${_DIR_CACHE}/stats         ${_DIR_WEB}/stats

EXPOSE 3875
ENTRYPOINT [ "/usr/local/bin/duplicacy_web" ]

COPY ./files/ /

VOLUME ["/var/cache/duplicacy", "/etc/duplicacy"]
