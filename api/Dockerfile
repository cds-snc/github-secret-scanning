ARG BASE_IMAGE="python:3.13-alpine3.19@sha256:8287ca207e905649e9f399b5f91a119e5e9051d8cd110d5f8c3b4bd9458ebd1d"
FROM ${BASE_IMAGE} as builder

ARG RIE_VERSION="v1.10"

RUN apk add --no-cache \
    autoconf \
    automake \
    build-base \
    gcc \
    libc-dev \
    libcurl \
    libstdc++ \
    libtool \
    make \
    cmake \
    python3-dev \
    wget

# Install libexecinfo-dev from the Alpine v3.16 repository
RUN apk add --no-cache --update --repository=https://dl-cdn.alpinelinux.org/alpine/v3.16/main/ \
    libexecinfo-dev    

RUN wget https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/${RIE_VERSION}/aws-lambda-rie

RUN mkdir -p /pymodules \
    && pip install awslambdaric --target /pymodules

COPY ./requirements.txt /
RUN pip install -r /requirements.txt --target /pymodules

# Lambda API image
FROM ${BASE_IMAGE} as lambda

COPY --from=builder /pymodules /pymodules
COPY --from=builder /aws-lambda-rie /usr/bin/aws-lambda-rie

# Build variables
ARG FUNCTION_DIR="/function"
ARG GIT_SHA
ENV GIT_SHA=$GIT_SHA
ENV PYTHONPATH="/pymodules"

RUN apk upgrade --no-cache \
    && apk add --no-cache \
    binutils \
    libstdc++

COPY bin/entry.sh /
RUN chmod 555 /usr/bin/aws-lambda-rie /entry.sh

# Copy function code
WORKDIR ${FUNCTION_DIR}
COPY . ${FUNCTION_DIR}

ENTRYPOINT [ "/entry.sh", "main.handler" ]