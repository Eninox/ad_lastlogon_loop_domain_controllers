
Import-Module ActiveDirectory

# Récupérer la liste de tous les DC du domaine AD
$DCList = Get-ADDomainController -Filter * | Sort-Object Name | Select-Object Name

# Liste utilisateurs par OU et export propriétés cible
$TargetOU = "OU=XXX,OU=XXX,DC=domaine,DC=domain"
$TargetUserList = Get-ADUser -Filter * -SearchBase $TargetOU -Properties * | Select-Object SamAccountName,Enabled,Description,EmployeeId,EmailAddress,whenCreated,whenChanged,PasswordNeverExpires,PasswordLastSet,DistinguishedName,@{Name="LastlogonT";Expression={[datetime]::FromFileTime($_."LastLogonTimeStamp")}}

# Initialiser le LastLogon sur $null comme point de départ
$TargetUserLastLogon = $null

# Création d'un tableau vide
$LastLogonTab = @()

foreach ($TargetUser in $TargetUserList) {

    $TargetUserSam = $TargetUser.SamAccountName

    Foreach($DC in $DCList) {

            $DCName = $DC.Name
            
            Try {                
                # Récupérer la valeur de l'attribut lastLogon à partir d'un DC (chaque DC tour à tour)
                $LastLogonDC = Get-ADUser -Identity $TargetUserSam -Properties lastLogon -Server $DCName

                # Convertir la valeur au format date/heure
                $LastLogon = [Datetime]::FromFileTime($LastLogonDC.lastLogon)

                # Si la valeur obtenue est plus récente que celle contenue dans $TargetUserLastLogon
                # la variable est actualisée : ceci assure d'avoir le lastLogon le plus récent à la fin du traitement
                If ($LastLogon -gt $TargetUserLastLogon) {
                    $TargetUserLastLogon = $LastLogon
                }

                # Nettoyer la variable
                Clear-Variable -Name "LastLogon"
                }

            Catch {
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
    }
    
    $LastLogonTab += New-Object -TypeName PSCustomObject -Property @{
        SamAccountName = $TargetUserSam
        LastLogonDate = $TargetUserLastLogon.ToString("dd/MM/yyyy")
        LastLogonHour = $TargetUserLastLogon.ToString("HH:mm:ss")
        LastLogonTimeStamp = $TargetUser.LastlogonT
        Enabled = $TargetUser.Enabled
        EmailAddress = $TargetUser.EmailAddress
        Description = $TargetUser.Description
        WhenChanged = $TargetUser.whenChanged
        WhenCreated = $TargetUser.whenCreated
        PasswordNeverExpires = $TargetUser.PasswordNeverExpires
        PasswordLastSet = $TargetUser.PasswordLastSet
        DistinguishedName = $TargetUser.DistinguishedName
    }
    
    Write-Host "Date de derniere connexion de $TargetUserSam : $TargetUserLastLogon"
   
    Clear-Variable -Name "TargetUserLastLogon"
}

Write-Host $LastLogonTab | Format-Table

$LastLogonTab | Export-Csv -Path "chemin\du\dossier\lastlogon_OU_users.csv" -NoTypeInformation -Delimiter ";"