FROM python:3.7-alpine

ENV APP_HOME="/app"

RUN mkdir -p ${APP_HOME}
WORKDIR ${APP_HOME}

COPY requirements.txt .

RUN \
 apk add --no-cache postgresql-libs make && \
 apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev && \
 python3 -m pip install -r requirements.txt --no-cache-dir && \
 apk --purge del .build-deps

COPY . .
 

ENTRYPOINT ["/app/docker-entrypoint.sh"]
