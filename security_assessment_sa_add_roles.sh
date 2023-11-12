#!/bin/bash

set -e

# Este script:
# a) Require de un project_id valido en GCP
# b) A partir del project id, obtiene el ID de la organizacion, lo guarda como ORG_ID
# c) Dentro de la organización asigna todos los roles en el array $AXMOS_SA_ROLES al Cloud AIM user $SA_NAME
# d) Dentro del proyecto asigna todos los roles en el array $ON_PROJECT_PERMISSIONS al Cloud AIM user $SA_NAME
# ATENCION: Este script parece estar en desuso y haber sido sobresedido por el script `triforce_assessment_sa_add_roles.sh`

SA_NAME=organization-scanner@axmos-triforce-assessment.iam.gserviceaccount.com;
PROJECT_ID=$1;

if [ -z "${PROJECT_ID}" ]; then
  echo "Error: Please provide a project ID as a command-line argument."
  echo "Ex: ./security_assessment_sa_add_roles.sh prj-one-prd"
  exit 1
fi


ORG_ID="$(gcloud projects get-ancestors $PROJECT_ID --format=json | jq -r '.[]|select(.type | startswith("org"))|.id')"

echo "==========================================================================================="
echo ""
echo "IMPORTANT: Please copy this Organization ID and send it to AXMOS through the Enrollment Form"
echo ""
echo "https://docs.google.com/forms/d/e/1FAIpQLScOPQYojW6ybB6OWyu6HhEE73K2qGEM2S7RlQhHjnRoX7FROQ/viewform"
echo ""
echo "Org Id: "${ORG_ID};
echo ""
echo "==========================================================================================="

AXMOS_SA_ROLES=(
roles/appengine.appViewer \
roles/artifactregistry.reader \
roles/bigquery.metadataViewer \
roles/bigtable.viewer \
roles/billing.viewer \
roles/cloudfunctions.viewer \
roles/cloudsql.viewer \
roles/composer.user \
roles/compute.networkViewer \
roles/compute.viewer \
roles/container.viewer \
roles/dataflow.viewer \
roles/dataproc.viewer \
roles/datastore.viewer \
roles/dns.reader \
roles/firebase.viewer \
roles/iam.securityReviewer \
roles/iam.serviceAccountViewer \
roles/logging.viewer \
roles/memcache.viewer \
roles/monitoring.alertPolicyViewer \
roles/monitoring.dashboardViewer \
roles/pubsub.viewer \
roles/redis.viewer \
roles/resourcemanager.folderViewer \
roles/resourcemanager.organizationViewer \
roles/run.viewer \
roles/recommender.viewer \
roles/securitycenter.adminEditor \
roles/serviceusage.serviceUsageConsumer \
roles/iam.serviceAccountUser \
roles/monitoring.viewer \
roles/bigquery.metadataViewer \
roles/serviceusage.serviceUsageAdmin \
roles/containerregistry.ServiceAgent
)

echo "Assigning roles to the service account at the organization..."
for role in "${AXMOS_SA_ROLES[@]}"
do
  echo "Assigning $role... to ${SA_NAME} at the organization";
  gcloud organizations add-iam-policy-binding ${ORG_ID} \
    --member=serviceAccount:"${SA_NAME}" \
    --role="${role}" \
    --no-user-output-enabled --quiet;
done

ON_PROJECT_PERMISSIONS=(
  roles/bigquery.jobUser \
  roles/bigquery.dataOwner \
  roles/bigquery.user
)

echo "Assigning roles to the service account in the project..."
for role in "${ON_PROJECT_PERMISSIONS[@]}"
do
  echo "Assigning ${role} to ${SA_NAME} in the project"

  gcloud iam service-accounts add-iam-policy-binding "${SA_NAME}" \
    --member=serviceAccount:"${SA_NAME}" \
    --role="${role}" \
    --no-user-output-enabled --quiet
done


echo "Script completed successfully."
