#!/bin/bash

set -e

# Este script:
# a) Require de un project_id válido en GCP
# b) A partir del project id, obtiene el ID de la organizacion, lo guarda como ORG_ID
# c) Dentro de la organización, crea un rol, llamado `axmos_assessment_org_viewer`  con todos los permisos listados en `triforce-custom-role.yaml`
# d) Dentro de la organización asigna todos los roles en el array $AXMOS_SA_ROLES al Cloud AIM user $SA_NAME
# e) Dentro del proyecto asigna todos los roles en el array $ON_PROJECT_PERMISSIONS al Cloud AIM user $SA_NAME
# f) Luego declara en $BILLING_TABLE la tabla de bigquery que se usa para exportar los gastos del cliente
# g) Finalmente, invita al usuario a ingresar la información al formulario web de Triforce

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
 roles/securitycenter.adminEditor \
 roles/cloudasset.owner \
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
  roles/run.admin \
  roles/cloudbuild.builds.editor \
  roles/storage.admin \
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

echo "Insert Billing Export Dataset"
bq ls --format=pretty
read -p "Selected Dataset Dataset name: " DATASET
BILLING_TABLE=$PROJECT_ID.$DATASET.$(bq ls $DATASET | grep -o 'gcp_billing_export_v1_[0-9A-F_]*' | head -n 1)

echo "==========================================================================================="
echo ""
echo "IMPORTANT: Please copy the required information and send it to AXMOS through the Enrollment Form"
echo ""
echo "https://docs.google.com/forms/d/e/1FAIpQLSfUkDNQkSFr5hYlysSp202qpmcBEgg1-MC1sZavuuq9K5HG6Q/viewform"
echo ""
echo "Organization ID: ${ORG_ID}";
echo "Billing Export Tables List: ${BILLING_TABLE}"
echo ""
echo "==========================================================================================="

