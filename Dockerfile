ARG ARCH=x86_64

FROM quay.io/pypa/manylinux2010_${ARCH}:latest as base

FROM base as builder
WORKDIR /home/builder
RUN yum -y update \
    && yum -yq install cmake \
    && yum clean all
COPY ./scripts/ ./scripts/
RUN  ./scripts/download-mbedtls.sh 2.16.7 /usr/local/src \
  && ./scripts/install-mbedtls.sh /usr/local/src /usr/local \
  && cp /usr/local/src/LICENSE LICENSE.mbedtls \
  && rm -r /usr/local/src
COPY ./setup.py ./README.rst ./
COPY ./src/ ./src/
RUN ./scripts/build-wheels.sh

FROM base
WORKDIR /root
COPY ./scripts/ ./scripts/
COPY ./README.rst ./
COPY --from=builder /home/builder/wheelhouse/ ./wheelhouse/
COPY ./tests/ ./tests/
