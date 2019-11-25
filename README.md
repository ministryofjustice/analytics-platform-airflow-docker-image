[![Docker Repository on Quay](https://quay.io/repository/mojanalytics/airflow/status "Docker Repository on Quay")](https://quay.io/repository/mojanalytics/airflow)

# analytics-platform-airflow-docker-image
Repository used to build Airflow docker image used by [airflow-k8s](https://github.com/ministryofjustice/analytics-platform-helm-charts/tree/master/charts/airflow-k8s) and [airflow-sqlite](https://github.com/ministryofjustice/analytics-platform-helm-charts/tree/master/charts/airflow-sqlite) helm charts.

Reasons for this were:
- Use of Python3 (official image was using Python 2)
- Use of our [fab-oidc](https://github.com/ministryofjustice/fab-oidc) module which adds support for OIDC to [Flask-AppBuilder](https://flask-appbuilder.readthedocs.io/en/latest/) apps, used by Airflow.
- added `redis` Python module so that Airflow's webserver instances can store session data in redis
- have control over version of Airflow used

## How to update

1. Update `AIRFLOW_VERSION` in the Dockerfile.
2. Compute the SHA of the Airflow release by running:  
   ```curl -o AIRFLOW_FILENAME --location AIRFLOW_TARBALL_URL && shasum AIRFLOW_FILENAME```  
   substituting `AIRFLOW_FILENAME` with the filename of the release (for example, `1.10.6.zip`) and `AIRFLOW_TARBALL_URL` with the URL of the release file (for example, `https://github.com/apache/airflow/archive/1.10.6.zip`).
3. Update `AIRFLOW_SHA` in the Dockerfile with the computed SHA.
4. Create a new release.