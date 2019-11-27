Function Get-BasicADObject {	
	param
	(
		[String]$Ldap = "dc=" + $env:USERDNSDOMAIN.replace(".", ",dc="),		
		[String]$Filter = "(&(objectCategory=person)(objectClass=user))"
	)

	if ($pscmdlet.ShouldProcess($Ldap, "Get information about AD Object")) {
		$searcher = [adsisearcher]$Filter
			
		$Ldap = $Ldap.replace("LDAP://", "")
		$searcher.SearchRoot = "LDAP://$Ldap"
		$results = $searcher.FindAll()
	
		$ADObjects = @()
		foreach ($result in $results) {
			[Array]$propertiesList = $result.Properties.PropertyNames
			$obj = New-Object PSObject
			foreach ($property in $propertiesList) { 
				$obj | add-member -membertype noteproperty -name $property -value ([string]$result.Properties.Item($property))
			}
			$ADObjects += $obj
		}
	  
		Return $ADObjects
	}
}


