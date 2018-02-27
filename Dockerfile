ARG NODE_VERSION=7

FROM node:${NODE_VERSION}

ARG ELM_ES_PORT=8000

ENV http_proxy=${http_proxy} \
    https_proxy=${http_proxy} \
    HTTP_PROXY=${http_proxy} \
    HTTPS_PROXY=${http_proxy} \
    no_proxy=${no_proxy} \
    NO_PROXY=${no_proxy} \
    ELM_ES_PORT=${ELM_ES_PORT}

RUN mkdir -p /usr/src/app

ENV PATH="$PATH:/usr/src/app/node_modules/.bin"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod a+x /usr/local/bin/entrypoint.sh

WORKDIR /usr/src/app

VOLUME /usr/src/app

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

EXPOSE $ELM_ES_PORT

CMD [ "elm-reactor", "-p $ELM_ES_PORT", "-a 0.0.0.0" ]
