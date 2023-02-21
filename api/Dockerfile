ARG BASE_IMAGE="python:3.11.2-alpine3.16@sha256:bbb8443eb8552bb38313c17e2f92a41f1604c4766de32289abfe3434bddc0c6c"
FROM ${BASE_IMAGE} as builder

ARG RIE_VERSION="v1.10"

RUN apk add --no-cache \
    autoconf \
    automake \
    build-base \
    gcc \
    libc-dev \
    libcurl \
    libexecinfo-dev \
    libstdc++ \
    libtool \
    make \
    cmake \
    python3-dev \
    wget

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
    aws-cli \
    binutils \
    libstdc++

COPY bin/entry.sh /
RUN chmod 555 /usr/bin/aws-lambda-rie /entry.sh

# Copy function code
WORKDIR ${FUNCTION_DIR}
COPY . ${FUNCTION_DIR}

ENTRYPOINT [ "/entry.sh", "main.handler" ]