FROM python:3.9.10-alpine3.15 as base

ARG PORT
ENV PORT=${PORT}
ARG ENVIRONMENT
ENV ENVIRONMENT=${ENVIRONMENT}

ENV FLASK_APP=main.py

RUN python -m pip install --upgrade pip

RUN mkdir /app/
WORKDIR /app/

COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

COPY "${FLASK_APP}" /app/

#For Logs
VOLUME /var/log/flask

#For ConfigMap
VOLUME /etc/flask

################### START NEW IMAGE: PRODUCTION ###################
FROM base as prod

RUN apk update
RUN apk add busybox-extras
RUN apk add curl


CMD flask run -h 0.0.0.0 -p "${PORT}"