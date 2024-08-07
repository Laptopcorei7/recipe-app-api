FROM python:3.12.3-alpine3.18
LABEL maintainer="laptopcorei7"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

RUN python -m venv /py

RUN /py/bin/pip install --upgrade pip

RUN apk add --update --no-cache postgresql-client jpeg-dev

RUN apk add --update --no-cache --virtual .tmp-build-deps build-base postgresql-dev musl-dev zlib zlib-dev

RUN /py/bin/pip install -r /tmp/requirements.txt

RUN if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi

RUN rm -rf /tmp

RUN apk del .tmp-build-deps

RUN adduser --disabled-password --no-create-home django-user

RUN mkdir -p /vol/web/media

RUN mkdir -p /vol/web/static

RUN mkdir -p /app/uploads/recipe

RUN chown -R django-user:django-user /vol /app/uploads

RUN chmod -R 755 /vol /app/uploads

ENV PATH="/py/bin:$PATH"

USER django-user