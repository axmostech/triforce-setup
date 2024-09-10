# Triforce - Google Cloud Service Account Generator

This is a bash script used for assigning specific roles at organization level to a service account in Google Cloud Platform.

## Dependencies

This script requires the following dependencies:

- Google Cloud SDK (includes `gcloud`)
- `jq`

Ensure these are installed and properly configured on your system. This script has been tested on Debian-based systems, but should work on any system with the above dependencies installed.

## Permissions

The executing user must have the following IAM permissions to run this script:


- `roles/resourcemanager.organizationAdmin`:  Predefined role to manage organization IAM roles.

- `roles/resourcemanager.organizations.setIamPolicy`: Specific permission to manage organization IAM roles.

Please ensure that the executing user has these permissions in the Google Cloud Platform IAM settings.

## Usage

To use this script, run it in your terminal with the billing project ID as argument:

```bash
./triforce_assessment_sa_add_roles.sh <project_id>
```
