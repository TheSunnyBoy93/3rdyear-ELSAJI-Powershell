########## ELSAJI (AK,JC,LM,SZ) ##########
#Forcer le type d'execution du script
Set-ExecutionPolicy Unrestricted

#Importation du module Active Directory.
import-module activedirectory

#Importation du module NTFS Security
import-module NTFSsecurity

#Effacer la page
Clear

#Continue en cas d'erreur
$ErrorActionPreference = "continue"

#Variable globale	
	$pathusers2= "E:\ESGI\classes$\"
    $pathusers3= "E:\ESGI\Eleves$\"
    $pathusers4= "E:\ESGI\Filieres$\"
	#$Groupe1 = "eleves"
	$ou1 = "OU=etudiants,DC=force2,DC=net"
	$creationOU = "DC=force2,DC=net"
	$Domaine = "@force2.net"
	$pathusers1 = $pathusers3 + "\" + $login
	
Write-Host " `n #################### BIENVENUE DANS POWERSHELL ELSAJI #################### `n" -Foreground "green"
#Le choix d'executer ou pas le script
$choix1 = Read-Host "`nSi voulez-vous executer une action taper "Y" pour oui ou "N" pour sortir "

#La boucle While permettant de continuer ou pas 
while ($choix1 -eq "Y"){
    Write-Host " `n #################### Selectionner une des options suivantes #################### `n" -Foreground "green"
	#On choisi un choix parmi les differentes choix 
    Write-Host [1]- Creer une OU `n
    Write-Host [2]- Importer des utilisateurs fichier csv `n
    Write-Host [3]- Creer un nouvel utilisateur `n
    Write-Host [4]- Creer un groupe et ajout des users dans le groupe `n
    Write-Host [5]- Ajouter un utilisateur dans un groupe `n
    Write-Host [6]- Supprimer un utilisateur `n
    Write-Host [7]- Supprimer un groupe `n
    Write-Host [8]- Quitter `n
	
	#l'utilisateur choisi un choix
    $choix = Read-Host "Choisissez une option "
	
	#execution du choix entrer par l'utilisateur
	Switch ($choix)
	{
	#1er Choix : creation  D'OU
		1	
			{
			# On vérifie si l'ou existe sinon la créer *************************************************************
				$NomOU = Read-Host "Merci de Rentrer le Nom du l'OU à Creer"
				if ((GET-ADOrganizationalUnit -Filter {Name -eq $NomOU}) -eq $null)
					{
	   
				# Création de l'utilisateur
				#********************Création des OU********************************
		
						New-ADOrganizationalUnit -Name $NomOU -Path $creationOU
						Write-Host "L'utilisateur : $NomOU est cree !" -Foreground "green"
					}
				else:{Write-Host "Le Nom de l'OU : $NomOU n'est pas cree ou existe deja !" -Foreground "red"}
			}
	#2e  Choix : Importation des utilisateurs depuis un fichier csv
		2
			{
			# Variables initiales
				Write-Host "`n l'en-tete du fichier csv doit ressembler a ca ==> NOM;PRENOM;IDENTIFIANT;PASSWORD;MESSAGERIE `n" -BackgroundColor DarkGreen
				$File = Read-Host "Merci de Rentrer le chemin complet du fichier csv"
				$Domain = (Get-ADDomain).DNSRoot
			# Actions
				$users = Import-Csv $File -Delimiter ";" 
				Foreach($user in $users) {
	 
				Write-Host "`n====================================================================" -BackgroundColor DarkGray
			# Variables fixes
				$nom = $user.NOM
				$prenom = $user.PRENOM
				$login = $user.IDENTIFIANT
				$mdp = $user.PASSWORD
				$displayname= $PRENOM + " " + $NOM
				$Domaine = "force2.net"
				$Mail= $user.MESSAGERIE
				#$CLASSE = $user.CLASSE
				#$FILIERE = $user.FILIERE
				#$expirdate= $user.ExpirationDate 
				#$chpassword= $user.ChangePassword
				#$chpassword1= $false
				#$script= $user.Script
				#$util= $user.IDENTIFIANT + $domaine
			
			
			
			#Verifiez si le compte utilisateur existe dejà dans AD
			#Get-ADUser -filter '*' -searchbase $ou1
				if ((Get-ADuser -Filter {Name -eq $login}) -eq $null)
					{
						New-ADUser -Name $login -givenname $prenom -Surname $nom -UserPrincipalName $mail -AccountPassword (ConvertTo-SecureString  $mdp -AsPlainText -Force) -PasswordNeverExpires $true -CannotChangePassword $true -DisplayName $displayname -Enabled $true -Path $ou1
					# Création le dossier de base ************************************************
						Set-Location $pathusers3
						New-Item -Name $login -ItemType directory

						$dossier= $pathusers1

					# Droits NTFS : on ajoute l'utilisateur en LM ********************************
					#Add-NTFSsecurity -Path $dossier -Account $login -AccessRights Modify
			
						Write-Host "L'utilisateur : $nom est cree !" -Foreground "green"
					}
			#Write-Host "utilisateur $nom ajoute" -BackgroundColor DarkGreen
				else
					{
						Write-Host "L'utilisateur : $nom n'est pas cree ou existe deja !" -Foreground "red"}
					}
			}
	#3e  Choix : reation d'un nouvel utilisateur
		3
			{
				Write-Host "`n ************************* Creation User ************************* `n"
			#l’Utilisateur renseigner les champs	
				$nom = Read-Host "Merci de Rentrer le Nom de l’Utilisateur à Creer"
				$prenom = Read-Host "Merci de Rentrer le preom de l’Utilisateur à Creer"
				$login = Read-Host "Merci de Rentrer le Login de l’Utilisateur à Creer"
				$mdp = Read-Host "Merci de Rentrer le Mot de Passe de l’Utilisateur à Creer"
				$Mail = Read-Host "Merci de Rentrer le mail l’Utilisateur à Creer"
				$displayname = $nom +" "+$prenom

			#Verifiez si le compte utilisateur existe dejà dans AD
			#if (Get-ADUser -F {SamAccountName -eq $login})
			#Get-ADUser -filter '*' -searchbase $ou1
				if ((Get-ADUser -Filter {Name -eq $login}) -eq $null){
				
					New-ADUser -Name $login -givenname $prenom -Surname $nom -UserPrincipalName $Mail -AccountPassword (ConvertTo-SecureString  $mdp -AsPlainText -Force) -PasswordNeverExpires $true -CannotChangePassword $true -DisplayName $displayname -Enabled $true -Path $ou1
					# Création le dossier de base ************************************************
					Set-Location $pathusers3
					New-Item -Name $login -ItemType directory

					$dossier= $pathusers1

			# Droits NTFS : on ajoute l'utilisateur en LM ********************************
					#Add-NTFSsecurity -Path $dossier -Account $login -AccessRights Modify
	   
					Write-Host "L'utilisateur : $nom est cree !" -Foreground "green"
				}
			#Write-Host "utilisateur $nom ajoute" -BackgroundColor DarkGreen
				else
					{
						Write-Host "L'utilisateur : $nom n'est pas cree ou existe deja !" -Foreground "red"}
					}

	#4e  Choix :  Creation d'un groupe et ajout user
		4 
			{
				Write-Host " `n ************************* Creation Groupe ************************* `n"
			# L'utilisateur entre le nom du groupe
				$groupe = Read-Host "Merci de Rentrer le Nom du Groupe à Creer"
			
			# On vérifie si le Groupe filiere existe sinon le créer ************************************************    
				 
				if ((GET-ADOrganizationalUnit -Filter {Name -eq $groupe}) -eq $null)
					{
						New-ADGroup -Name $groupe -Path $ou1 -GroupScope Global -GroupCategory Security #-Path "OU=eleves,DC=force2,DC=net"
						Write-Host " `n Groupe $groupe ajoute `n" -BackgroundColor DarkGreen
					}
				else
					{
						Write-Host "Le groupe : $groupe n'est pas cree ou existe deja !" -Foreground "red"
					}
			
			# On peut ajouter plusieurs users en meme temps
			#[int] $nombre = Read-Host "Merci de Rentrer le Nombre d’Utilisateurs à Inserer dans le Groupe"

			#for ($i=1; $i -le $nombre; $i++)
			#	{
			#	Write-Host " `n ************************* Ajout user dans un Groupe ************************* `n"
			#	$nom = Read-Host "Merci de Rentrer le Nom de l’Utilisateur à Inserer dans le Groupe $groupe"
			#	if ((Get-ADUser -Filter {Name -eq $nom}) -ne $null)
			#		{
			#			Add-ADGroupMember -identity $groupe -Members $nom
			#			Write-Host " `n L’Utilisateur $nom a Bien Ete Insere dans le Groupe $groupe. `n" -BackgroundColor DarkGreen
			#
			#		}

			}
	#5e  Choix : Ajout user dans un groupe
		5
			{
				Write-Host " `n ************************* Ajouter un user dans un Groupe ************************* `n"
				$login1 = Read-Host "Merci de Rentrer le login de l'Utilisateur à Inserer dans le Groupe "
				$Groupe2 = Read-Host "Merci de Rentrer le Nom du Groupe dans lequel l'utilisateurva etre ajouter "
				if ((Get-ADUser -Filter {Name -eq $login}) -eq $null)
					{
						Add-ADGroupMember -Identity $Groupe2 -Members $login1
						Write-Host " `n L’Utilisateur $login1 a Bien Ete Insere dans le Groupe $Groupe2. `n" -BackgroundColor DarkGreen
					}
				else
					{
						Write-Host " `nl'utilisateur $login1 ou groupe $Groupe2 n'existe pas dans l'AD, Veillez verifier l'ortographe " -BackgroundColor DarkRed
					}
			}
	#6e  Choix : Suppression user 
		6 
			{
				Write-Host " `n ************************* Suppression User ************************* `n"
				$DelUser = Read-Host "Merci de Rentrer le Nom d'utilisateur a supprimer"
				if ((Get-ADUser -Filter {Name -eq $DelUser}) -ne $null)
					{
						Remove-ADUser -Identity $DelUser #-path $ou1
						Write-Host " `n Utilisateur $DelUser supprime `n " -BackgroundColor DarkGreen
					}
				else
					{
						Write-Host " `nCe Nom User : $DelUser n'existe pas dans l'AD, veillez verifier l'ortographe `n" -BackgroundColor DarkRed
					}
			}

	#7e  Choix :  Suppression Groupe
		7 
			{
				Write-Host " `n ************************* Suppression Groupe ************************* `n"
				$GroupDel = Read-Host "Merci de Rentrer le Nom du groupe a supprimer"
				if ((Get-ADGroup -Filter {Name -eq $GroupDel}) -ne $null)
					{
						Remove-ADGroup -Identity $GroupDel
						Write-Host " `n le groupe : $GroupDel supprime `n" -BackgroundColor DarkGreen
					}
				else
					{
						Write-Host " `n le groupe : $GroupDel n'est pas supprime n'existe pas dans l'AD, veillez verifier l'ortographe "-BackgroundColor DarkRed 
					}
			} 
	#8e  Choix : quitter le script
		8 
			{exit}

	}
}

     
#reboot un pc
	#shutdown -s -f -t 30 - m \\192.168.3.4

	#restart-computer -computername NomDeLaMachine -Force -wait -Delay 1
	#restart-computer -Confirm

