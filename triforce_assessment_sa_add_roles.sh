#!/usr/bin/env bash

set -e

# This script
# a) Requires a project id valid within GCP. It should be the billing project in the target organization
# b) Based on the project id, it obtains the organization id, saving it under under $ORG_ID
# c) Within the target organization, it creates a role named `axmos_assessment_org_viewer` with all the permisions listed in `triforce-custom-role.yaml`
# d) Within the organization it assigns all the roles in the array $AXMOS_SA_ROLES to the AIM user identifier by $SA_NAME
# e) Within the billing project, it assigns all the roles in the array $ON_PROJECT_PERMISSIONS to the AIM user $SA_NAME
# f) Declares under $BILLING_TABLE the BigQuery table used to export the organization costs (their billing table)
# g) Finally, it prints out $ORG_ID and $BILLING_TABLE inviting the user to fill in this info in the Triforce onboarding form

SA_NAME=organization-scanner@axmos-triforce-assessment.iam.gserviceaccount.com;
PROJECT_ID=$1;

if [ -z "${PROJECT_ID}" ]; then
  echo "Error: Please provide a project ID as a command-line argument."
  echo "Ex: ./full_assessment_sa_add_roles.sh prj-one-prd"
  exit 1
fi


ORG_ID="$(gcloud projects get-ancestors $PROJECT_ID --format=json | jq -r '.[]|select(.type | startswith("org"))|.id')"

gcloud iam roles create axmos_assessment_org_viewer --organization=$ORG_ID --file="triforce-custom-role.yaml" --quiet

AXMOS_SA_ROLES=(
 roles/iam.securityReviewer \
 organizations/$ORG_ID/roles/axmos_assessment_org_viewer
)

echo "Assigning roles to the service account in the organization..."
for role in "${AXMOS_SA_ROLES[@]}"
do
  echo "Assigning ${role}... to ${SA_NAME} at the organization";
  gcloud organizations add-iam-policy-binding "${ORG_ID}" \
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

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member=serviceAccount:"${SA_NAME}" \
    --role="${role}" \
    --no-user-output-enabled --quiet
done
echo "Looking for Billing Export Tables..."

for ds in $(bq ls --format=pretty --project_id=$PROJECT_ID | grep -o '[^| ]\+\(\+[^| ]\+\)*' | tail -n +3)
do
    for table in $(bq ls  --project_id=$PROJECT_ID $ds | grep -o 'gcp_billing_export[_a-zA-Z0-9]*')
    do
        BILLING_TABLES="$BILLING_TABLES \n $PROJECT_ID.$ds.$table"
    done
done

echo "==========================================================================================="
echo ""
echo "IMPORTANT: Please copy the required information and send it to AXMOS through the Enrollment Form"
echo ""
echo "https://docs.google.com/forms/d/e/1FAIpQLSfUkDNQkSFr5hYlysSp202qpmcBEgg1-MC1sZavuuq9K5HG6Q/viewform"
echo ""
echo "Project ID: ${PROJECT_ID}";
echo "Organization ID: ${ORG_ID}";
echo "Billing Export Tables List: "
echo -e $BILLING_TABLES
echo ""
echo "==========================================================================================="

