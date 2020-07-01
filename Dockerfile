#  Licensed to the Apache Software Foundation (ASF) under one   *
#  or more contributor license agreements.  See the NOTICE file *
#  distributed with this work for additional information        *
#  regarding copyright ownership.  The ASF licenses this file   *
#  to you under the Apache License, Version 2.0 (the            *
#  "License"); you may not use this file except in compliance   *
#  with the License.  You may obtain a copy of the License at   *
#                                                               *
#    http://www.apache.org/licenses/LICENSE-2.0                 *
#                                                               *
#  Unless required by applicable law or agreed to in writing,   *
#  software distributed under the License is distributed on an  *
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY       *
#  KIND, either express or implied.  See the License for the    *
#  specific language governing permissions and limitations      *
#  under the License.                                           *

FROM python:3.7-slim

ARG AIRFLOW_REPO="apache/airflow"
ARG AIRFLOW_VERSION="1.10.6"
ARG AIRFLOW_SHA="be54958a0b0b86abb2bdcdbc140709f38ee70f5e"

ARG MOJTOOLS_REPO="moj-analytical-services/mojap-airflow-tools"
ARG MOJTOOLS_VERSION="v0.0.1"
ARG MOJTOOLS_SHA="7fab22aef2cac08cf194fc83bb72a65a1b6b2b5f"

# install deps
RUN apt-get update -y && apt-get dist-upgrade -y && apt-get install -y \
    python-dev \
    build-essential \
    libssl-dev \
    software-properties-common \
    nodejs \
    curl

RUN pip install --upgrade pip setuptools

# install airflow
ARG AIRFLOW_FILENAME="${AIRFLOW_VERSION}.zip"
ARG AIRFLOW_TARBALL_URL="https://github.com/${AIRFLOW_REPO}/archive/${AIRFLOW_FILENAME}"
RUN curl -o ${AIRFLOW_FILENAME} --location ${AIRFLOW_TARBALL_URL} && \
    echo "${AIRFLOW_SHA}  ${AIRFLOW_FILENAME}" | shasum --check - && \
    SLUGIFY_USES_TEXT_UNIDECODE=yes pip install file:///./${AIRFLOW_FILENAME}#egg=apache-airflow[kubernetes,postgres] fab_oidc==0.0.8 redis==2.10.6 && \
    rm ${AIRFLOW_FILENAME}

# Install mojap-airflow-tools - probably don't need to check sha as it's but better safe than sorry
ARG MOJTOOLS_FILENAME="${MOJTOOLS_VERSION}.zip"
ARG MOJTOOLS_TARBALL_URL="https://github.com/${MOJTOOLS_REPO}/archive/${MOJTOOLS_FILENAME}"
RUN curl -o ${MOJTOOLS_FILENAME} --location ${MOJTOOLS_TARBALL_URL} && \
    echo "${MOJTOOLS_SHA}  ${MOJTOOLS_FILENAME}" | shasum --check - && \
    SLUGIFY_USES_TEXT_UNIDECODE=yes pip install file:///./${MOJAP_FILENAME}#egg=mojap-airflow-tools && \
    rm ${MOJTOOLS_FILENAME}

# install Node.js 10 LTS from official Node.js PPA
# NOTE: This is required to compile Airflow's static
#       assets.
# SEE: This article on how to install node on Debian
#      https://tecadmin.net/install-latest-nodejs-npm-on-debian/
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

# compile Airflow's static assets
# NOTE: At this stage `compile_assets.sh` is in `www_rbac`
#       but Airflow and its assets are in `www`.
ENV PYTHON_PIP_SITE_PACKAGES_PATH="/usr/local/lib/python3.7/site-packages"
RUN cd ${PYTHON_PIP_SITE_PACKAGES_PATH} && ${PYTHON_PIP_SITE_PACKAGES_PATH}/airflow/www_rbac/compile_assets.sh && rm -rf ${PYTHON_PIP_SITE_PACKAGES_PATH}/airflow/www/node_modules

# remove build deps and Node.js PPA
RUN apt-get --purge remove -y \
    build-essential  \
    libssl-dev \
    python-dev \
    software-properties-common \
    nodejs \
    && apt-get clean && rm /etc/apt/sources.list.d/nodesource.list

ENTRYPOINT ["/usr/local/bin/airflow"]
