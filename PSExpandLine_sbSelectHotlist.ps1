[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseDeclaredVarsMoreThanAssignments','')]

# Set key handlers for hotlist selection
$sbSelect =
{
	Param ($Key,$Arg)

	# Get the items from the appropriate list
	$chord     = $Key ? "Ctrl+$($Key.Key.ToString().Replace('D',''))" : $Module.DefaultHotlist
	$listItems = Get-Variable -Name hotlists -Scope 1 -ValueOnly
	$listItems = $listItems[$chord]
	$listItems = @($listItems | Select-Object -Unique)

	If ($listItems)
	{
		# Create an ordered list for rapid matching
		$matchList = [Ordered]@{}
		$i         = 0
		$listItems | ForEach-Object {
			[PSCustomObject]@{
				Item   = $_
				Posn   = ($i++)
				Length = $_.Length
			}
		} `
		| Sort-Object @{ Expression = 'Length'; Descending = $true },@{ Expression = 'Posn'; Ascending = $true } `
		| ForEach-Object { $matchList[$_.Item] = $_.Posn }

		# Set the variables in the parent scope
		Set-Variable -Name listPosn  -Value 0          -Scope 1
		Set-Variable -Name listItems -Value $listItems -Scope 1
		Set-Variable -Name matchList -Value $matchList -Scope 1
	}
	Else
	{
		# Reset the variables in the parent scope
		Set-Variable -Name listItems -Value $null -Scope 1
		Set-Variable -Name matchList -Value $null -Scope 1
	}
}
