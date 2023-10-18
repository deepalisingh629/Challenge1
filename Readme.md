- Used terraform to create application infrastructure in Azure.

Azure Function app
Azure web app
Storage account & key vault(with access policies)
vnet & subnets
log analytics & application insights

- Currently drafted Tf code as resource block, we can get this converted in module and upload it to centralised repositoty and used module source as git repo.
- We have dev,uat, stg & prod environment here. we can set the pipeline either in Azure Devops or Github to provision the resources.
- When any commit happens to feature branch wrt dev, PR should show TF plan changes for dev and so on.
- Terraform apply should only work, oncre someone approves the pipeline for TF apply
- I have assumed that DB is on on-prem server(previously worked on similar scenarios) where we used in variables appsettings.json connection string with serviceaccount username & pwd. This creds were setup in octopus deploy and getting updated with actual values at run time.
