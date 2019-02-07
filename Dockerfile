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

FROM python:3.6-slim

ARG AIRFLOW_REPO="apache/airflow"
ARG AIRFLOW_VERSION="1.10.2"
ARG AIRFLOW_SHA="6418cf5cabf830212892fe5b3f02c43efb316e93"


# install deps
RUN apt-get update -y && apt-get install -y \
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
    SLUGIFY_USES_TEXT_UNIDECODE=yes pip install file:///./${AIRFLOW_FILENAME}#egg=apache-airflow[kubernetes,postgres] fab_oidc==0.0.6 redis==2.10.6 && \
    rm ${AIRFLOW_FILENAME}

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
ENV PIP_PACKAGES_PATH="/usr/local/lib/python3.6/site-packages"
RUN cd ${PIP_PACKAGES_PATH} && ${PIP_PACKAGES_PATH}/airflow/www_rbac/compile_assets.sh && rm -rf ${PIP_PACKAGES_PATH}/airflow/www/node_modules

# remove build deps and Node.js PPA
RUN apt-get --purge remove -y \
    build-essential  \
    libssl-dev \
    python-dev \
    software-properties-common \
    nodejs \
    && apt-get clean && rm /etc/apt/sources.list.d/nodesource.list

ENTRYPOINT ["/usr/local/bin/airflow"]
