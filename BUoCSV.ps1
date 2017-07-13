# Prompt for file name and read into an array, and for an output file name
$fileName = Read-Host -Prompt 'Enter Business Units file name'
$fileOut = Read-Host -Prompt 'Enter output file name'
$fileInput = Get-Content $fileName 
$fileSize = $fileInput.Length
$fileOutput = @()

$Application = ''

# Loop through array
for($i = 0; $i -lt $fileSize; ++i)
{
	# Reset Software Service and URL variables
	$SoftwareService = ''
	$URL = ''
	
	# write variable to see if any values should be output
	$write = 0
	
	# Switch to check for the strings needed and assign them to the correct variable
	Switch -regex ($fileInput[$i])
	{
		"-.name:.*"
		{
			if($fileInput[$i+2] -like "*APPLICATION")
			{
				$Application = $fileInput[$i] -Replace ".*: ", ''
			}
		}
		"....softwareService:.*"
		{
			$SoftwareService = $fileInput[$i] -Replace ".*: ", ''
			if($SoftwareService -ne "HTTP")
			{
				++$write
			}
		}
		"....label:.*"
		{
			# The initial use case for this was to see all the URLs that were being added to business units to catch what was hitting the auto HTTP Software Service
			if($fileInput[$i-2] -like "*HTTP")
			{
				$SoftwareService = "HTTP"
				$URL = $fileInput[$i] -Replace ".*: ", ''
				$URL = $URL -Replace "'", ''
				++$write
			}
		}
	}
	
	# if the write variable is not 0, add the variables to the fileOutput array
	if($write -ne 0)
	{
		$row = New-Object PSObject
		$row | Add-Member -MemberType NoteProperty -Name 'Application' -Value $Application
		$row | Add-Member -MemberType NoteProperty -Name 'Software Service' -Value $SoftwareService
		$row | Add-Member -MemberType NoteProperty -Name 'URL' -Value $URL
		$fileOutput += $row
	}
}

# Create the CSV from the $row object
$fileOutput | Export-CSV -Path $fileOut -NoTypeInformation