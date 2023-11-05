export SA_NAME=organization-scanner@axmos-triforce-assessment.iam.gserviceaccount.com;
export PROJECT_ID=$1;

if [ -z "$PROJECT_ID" ]; then
  echo "Error: Please provide a project ID as a command-line argument."
  echo "Ex: ./full_assessment_sa_add_roles.sh prj-one-prd"
  exit 1
fi


ORG_ID="$(gcloud projects get-ancestors $PROJECT_ID --format=json | jq -r '.[]|select(.type | startswith("org"))|.id')"

echo "==========================================================================================="
echo ""
echo "IMPORTANT: Please copy this Organization ID and send it to AXMOS throw the Enrollment Form"
echo ""
echo "https://docs.google.com/forms/d/e/1FAIpQLSfUkDNQkSFr5hYlysSp202qpmcBEgg1-MC1sZavuuq9K5HG6Q/viewform"
echo ""
echo "Org Id: "$ORG_ID;
echo ""
echo "==========================================================================================="

gcloud iam roles create axmos_assessment_org_viewer --organization=$ORG_ID --file="triforce-custom-role.yaml" --quiet

AXMOS_SA_ROLES=(
"roles/securitycenter.adminEditor" \
"roles/cloudasset.owner" \
"organizations/$ORG_ID/roles/axmos_assessment_org_viewer"
)


echo "Assigning roles to the service account at the organization..."
for role in "${AXMOS_SA_ROLES[@]}"
do
  echo "Assigning $role... to $SA_NAME at the organization";
  gcloud organizations add-iam-policy-binding ${ORG_ID} \
    --member=serviceAccount:"$SA_NAME" \
    --role="$role" \
    --no-user-output-enabled --quiet;
done

ON_PROJECT_PERMISSIONS=(
  'roles/run.admin' \
  'roles/cloudbuild.builds.editor' \
  'roles/storage.admin' \
  'roles/bigquery.jobUser' \
  'roles/bigquery.dataOwner' \
  'roles/bigquery.user'
)

echo "Assigning roles to the service account in the project..."
for role in "${ON_PROJECT_PERMISSIONS[@]}"
do
  echo "Assigning $role to $SA_NAME in the project"

  gcloud iam service-accounts add-iam-policy-binding $SA_NAME \
    --member=serviceAccount:$SA_NAME \
    --role="$role" \
    --project=$PROJECT_ID
    --no-user-output-enabled --quiet
done


echo "Script completed successfully."
