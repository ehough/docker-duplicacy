FROM alpine:latest

RUN ARCHITECTURE=linux_x64                                                                             && \
    SHA256_DUPLICACY=034720abb90702cffc4f59ff8c29cda61f14d9065e6ca0e4017ba144372f95d7                  && \
    SHA256_DUPLICACY_WEB=322e8865fa5f480952938be018725bf02bd0023a26512eb67216a9f0cb721726              && \
    VERSION_DUPLICACY=2.1.2                                                                            && \
    VERSION_DUPLICACY_WEB=0.2.10                                                                       && \
                                                                                                          \
    # add Bash for our entrypoint.sh, and ca-certificates so Duplicacy doesn't complain about certs
    apk update                                                                                         && \
    apk add --no-cache bash ca-certificates                                                            && \
                                                                                                          \
    # download, check, and install duplicacy
    wget --quiet -O /usr/local/bin/duplicacy                                                              \
        https://github.com/gilbertchen/duplicacy/releases/download/v${VERSION_DUPLICACY}/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY} && \
    echo "${SHA256_DUPLICACY}  /usr/local/bin/duplicacy" | sha256sum -s -c -                           && \
    chmod +x /usr/local/bin/duplicacy                                                                  && \
                                                                                                          \
    # downlooad, check, and install the web UI
    wget --quiet -O /usr/local/bin/duplicacy_web                                                          \
        https://acrosync.com/duplicacy-web/duplicacy_web_${ARCHITECTURE}_${VERSION_DUPLICACY_WEB}      && \
    echo "${SHA256_DUPLICACY_WEB}  /usr/local/bin/duplicacy_web" | sha256sum -s -c -                   && \
    chmod +x /usr/local/bin/duplicacy_web                                                              && \
                                                                                                          \
    # duplicacy_web expects to find the CLI binary in a certain location
    # https://forum.duplicacy.com/t/run-web-ui-in-a-docker-container/1505/2
    mkdir -p ~/.duplicacy-web/bin                                                                      && \
    ln -s /usr/local/bin/duplicacy ~/.duplicacy-web/bin/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY} && \
                                                                                                          \
    # redirect the log to stdout
    mkdir ~/.duplicacy-web/logs                                                                        && \
    ln -s /dev/stdout ~/.duplicacy-web/logs/duplicacy_web.log                                          && \
                                                                                                          \
    # listen on all interfaces
    echo '{"listening_address":"0.0.0.0:3875"}' > ~/.duplicacy-web/settings.json

ENTRYPOINT [ "/usr/local/bin/duplicacy_web" ]
