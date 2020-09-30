# <--- Change the following environment variables according to your Azure Service Principle name --->

Write-Output "Exporting environment variables"
$env:subscriptionId="subscriptionId"
$env:appId="appId"
$env:password="appPassword"
$env:tenantId="tenantId"
$env:resourceGroup="resourceGroup"
$env:arcClusterName="arcClusterName"

Write-Output  "Downloading the Azure Monitor onboarding script"
Invoke-WebRequest https://aka.ms/enable-monitoring-powershell-script -OutFile enable-monitoring.ps1

Write-Output "Onboarding the Azure Arc enabled Kubernetes cluster to Azure Monitor for containers"
az login --service-principal --username $env:appId --password $env:password --tenant $env:tenantId
az aks get-credentials --name $env:arcClusterName --resource-group $env:resourceGroup --overwrite-existing
$env:azureArcClusterResourceId = $(az resource show --resource-group $env:resourceGroup --name $env:arcClusterName --resource-type "Microsoft.Kubernetes/connectedClusters" --query id -o tsv)
$env:kubeContext = kubectl config current-context

.\enable-monitoring.ps1 -clusterResourceId $env:azureArcClusterResourceId -servicePrincipalClientId $env:appId -servicePrincipalClientSecret $env:password -tenantId $env:tenantId -kubeContext $env:kubeContext

rm enable-monitoring.ps1
