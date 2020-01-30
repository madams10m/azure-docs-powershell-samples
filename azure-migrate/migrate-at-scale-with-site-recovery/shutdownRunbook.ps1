param ( 
        [Object]$RecoveryPlanContext 
      ) 

Write-Output $RecoveryPlanContext

if($RecoveryPlanContext.FailoverDirection -ne 'PrimaryToSecondary')
{
    Write-Output 'Script is ignored since Azure is not the target'
}
else
{

    $VMinfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name
    $vmMap = $RecoveryPlanContext.VmMap


    Write-Output ("Found the following VMGuid(s): `n" + $VMInfo)

    if ($VMInfo -is [system.array])
    {

        Write-Output "Found multiple VMs in the Recovery Plan"
    }
    else
    {
        Write-Output "Found only a single VM in the Recovery Plan"
    }

    $RGName = $RecoveryPlanContext.VmMap.$VMInfo.ResourceGroupName

    Write-OutPut ("Name of resource group: " + $RGName)
}
Try
 {
    "Logging in to Azure..."
    $Credential = Get-Credential
    Connect-AzAccount -Credential $Credential -Tenant "xxxx-xxxx-xxxx-xxxx" -ServicePrincipal

    $Conn = Get-AutomationConnection -Name AzureRunAsConnection 
     Add-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    "Selecting Azure subscription..."
    Select-AzSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 

    $credential = Get-AutomationPSCredential -Name 'AzureCredential' 
    Login-azAccount -Credential $credential 
    Select-azSubscription -SubscriptionId $AzureSubscriptionId 

# Ensures you do not inherit an azContext in your runbook
Disable-azContextAutosave –Scope Process

$connection = Get-AutomationConnection -Name AzureRunAsConnection

# Ensures you do not inherit an azContext in your runbook
Disable-azContextAutosave –Scope Process

$connection = Get-AutomationConnection -Name AzureRunAsConnection

while(!($connectionResult) -And ($logonAttempt -le 10))
{
    $LogonAttempt++
    # Logging in to Azure...
    $connectionResult =    Connect-azAccount `
                               -ServicePrincipal `
                               -Tenant $connection.TenantID `
                               -ApplicationID $connection.ApplicationID `
                               -CertificateThumbprint $connection.CertificateThumbprint

    Start-Sleep -Seconds 30
}

$AzureContext = Select-azSubscription -SubscriptionId $connection.SubscriptionID

Get-azVM -ResourceGroupName myResourceGroup -azContext $AzureContext


 }
Catch
 {
      $ErrorMessage = 'Login to Azure subscription failed.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
 }


#Set Recovery Service Vault Context
$Vault = Get-azRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $RecoveryServicesVaultName
$VaultSettings = Set-azRecoveryServicesASRVaultContext -Vault $Vault
$fabric = Get-azRecoveryServicesAsrFabric -name $fname -WarningAction SilentlyContinue
$pc = Get-azRecoveryServicesAsrProtectionContainer -Fabric $fabric
$pcm = Get-azRecoveryServicesAsrProtectionContainerMapping -ProtectionContainer $pc

$RCPLAN = Get-azRecoveryServicesAsrRecoveryPlan -name "runbook-plan"

$RCitem = $rcplan.groups.replicationprotecteditems.name

foreach ( $item in $RCitem) {
    Get-azVm | Where-Object { $_.Name -eq $item } | stop-azvm -Force
    write-output $item
}
    




    

    



