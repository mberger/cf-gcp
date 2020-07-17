# Michael Berger Terraform Technical Challenge.

## The over all 
## Instance Types
I chose f1 micros for this exercise. The reasoning is pretty simple, there is no workload that will take place on these instances and I'm trying to stay within the $300 credit limit from Google. The RHEL 7 instance has a default disk size of 20 GB which is what the requirements stated, so there's no explicid call to disk size in the main.tf file.

## Problems with the 

## Creating Shared VPC.
I ran into some problems creating Shared VPCs as I had never done so. The main problem was perimssions. I had to research the following permissions and add them to my normail account user, as well as the service account user I used for automation. 
Ensure that the application default credentials have permission to create and manage projects and Shared VPCs (sometimes called 'XPN'). The example also requires you to specify a billing account, since it does start up a few VMs.

Regular Accounts:
    gcloud organizations add-iam-policy-binding 325998602966 --member='user:support@internetinnovation.com' --role="roles/compute.xpnAdmin"
ServiceAccounts:
    gcloud organizations add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/compute.xpnAdmin"
    gcloud organizations add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/compute.organizations.enableXpnHost"

Regular Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='user:support@internetinnovation.com' --role="roles/compute.xpnAdmin"
Service Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/compute.xpnAdmin"

Regular Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='user:support@internetinnovation.com' --role="roles/resourcemanager.projectIamAdmin"
Service Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/resourcemanager.projectIamAdmin"


User I used. This account was a service account I have Owner org level permissions. I know that's a no-no but I was going to ease of creation first and this account will be destroyed later.
    terraform@michaelberger-terraform-admin.iam.gserviceaccount.com


THe output at the end of the build would be the external IP address of the stand alone machine.

 had a problem with metadata_startup_script, found some help here - https://serverfault.com/questions/1017276/use-metadata-startup-script-in-google-cloud-template-in-terraform
This was my starting point for the most part today:
    https://github.com/terraform-providers/terraform-provider-google/tree/master/examples/shared-vpc

## How to
Begin by downloading your credentials from Google Cloud Console; the default path for the downloaded file is ~/.gcloud/Terraform.json. If you use another path, update the credentials_file_path variable. Ensure that these credentials have Organization-level permissions - this example will create and administer projects.

Run the following to build the infrastructure: 
    terraform init \
            -var="region=us-useast1" \
            -var="region_zone=us-east1-b" \
            -var="org_id=325998602966" \
            -var="billing_account_id=01B494-EFBA64-4E3B48"

    terraform plan \
        -var="region=us-useast1" \
        -var="region_zone=us-east1-b" \
        -var="org_id=325998602966" \
        -var="billing_account_id=01B494-EFBA64-4E3B48"

    terraform apply \
        -var="region=us-useast1" \
        -var="region_zone=us-east1-b" \
        -var="org_id=325998602966" \
        -var="billing_account_id=01B494-EFBA64-4E3B48"

To destroy the infrastructure: 
    terraform destroy \
        -var="region=us-useast1" \
        -var="region_zone=us-east1-b" \
        -var="org_id=325998602966" \
        -var="billing_account_id=01B494-EFBA64-4E3B48"


## Random Notes:
getting base image names:
    gcloud compute images list