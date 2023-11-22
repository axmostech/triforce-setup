#!/usr/bin/env bash

set -e

#
# Attention: This script seems obsolete and superseded by script `triforce_assessment_sa_add_roles.sh` in this sasme directory
# This script
# a) Requires a project id valid within GCP. It should be the billing project in the target organization
# b) Based on the project id, it obtains the organization id, saving it under under $ORG_ID
# c) Within the organization it assigns all the roles in the array $AXMOS_SA_ROLES to the AIM user identifier by $SA_NAME
# d) Within the billing project, it assigns all the roles in the array $ON_PROJECT_PERMISSIONS to the AIM user $SA_NAME
#
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
echo "==========================================================================================="

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

echo "==========================================================================================="
echo "Assigning roles to the service account in the project..."
echo "==========================================================================================="

for role in "${ON_PROJECT_PERMISSIONS[@]}"
do
  echo "Assigning ${role} to ${SA_NAME} in the project"
  
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_NAME}" \
    --role="${role}" \
    --no-user-output-enabled --quiet
  
done


echo "Script completed successfully."
