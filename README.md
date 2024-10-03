# ad_lastlogon_loop_domain_controllers
Script d'interrogation de l'attribut LastLogon agrégée pour tous les contrôleurs de domaine (DC)
> Permet d'afficher la date exchaustive de lastlogon, tout DC confondu


#### 1. Identification des DC du domaine
#### 2. Identification de l'OU cible
#### 3. Interrogation du lastlogon pour chaque user, sur chaque DC avec retenue du lastlogon le plus récent
#### 4. Composition tableau de données et export csv
> sam, lastlogon, enable, mail address, description, whencreated, whenchanged, password never expires, password lastset, distinguished

Repris et modifié depuis une base it-connect https://github.com/it-connect-fr/PowerShell-ActiveDirectory/tree/main/Get-ADUserLastLogon
