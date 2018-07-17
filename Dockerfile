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

ARG AIRFLOW_REPO="apache/incubator-airflow"
ARG AIRFLOW_COMMIT="2c20ae81f98f4db17416cebaa9a05b4d0a3880cf"

# install deps
RUN apt-get update -y && apt-get install -y \
    python-dev \
    build-essential \
    curl \
    libssl-dev


RUN pip install --upgrade pip setuptools

# install airflow
RUN pip install https://github.com/${AIRFLOW_REPO}/archive/${AIRFLOW_COMMIT}.zip#egg=apache-airflow[kubernetes,postgres] fab_oidc==0.0.3

RUN apt-get --purge remove -y \
    build-essential  \
    libssl-dev \
    python-dev \
    && apt-get clean

ENTRYPOINT ["/usr/local/bin/airflow"]
