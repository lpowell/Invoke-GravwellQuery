<#
.SYNOPSIS
Gravwell Query API module

.DESCRIPTION
This module uses the Gravwell API module to retrieve query results. Configurations and query parameters can be saved into JSON files for repeated use.

.PARAMETER ServerIP
The IP and port of the API connection. <serverIP>:<port>

.PARAMETER Query
The string query to send to the server.

.PARAMETER Key
The Gravwell API Key to use.

.PARAMETER Save
Switch to save the JSON configuration into $ConfigurationFile.

.PARAMETER Load
Switch to load the JSON configuration in $ConfigurationFile

.PARAMETER ConfigurationFile
The name of a JSON configuration file to load.

.PARAMETER Duration
The Duration parameter to send with the query. Format 12h, 24h, etc.

.PARAMETER Format
The format parameter to send with the query. 

.PARAMETER OutFile
The name of a file to save results to. 

#>

function Invoke-GravwellQuery{
    param($ServerIP, $Query, $Key, [switch]$Save, [switch]$Load, $ConfigurationFile, $Duration, $Format, $OutFile)

    # Import or Export API configurations 
    if($Save -Or $Load){
        $Configuration = Import
    }else{
        $Properties =@{
            "ServerIP" = $ServerIP
            "Key" = $Key
            "Query" = $Query
            "Duration" = $Duration
            "Format" = $Format
        }
        $Configuration = New-Object psobject -Property $Properties
    }

    # Build base URL for webrequests
    $BaseURL = "http://" + $Configuration.ServerIP + "/api/search/direct"

    # Send to Requests
    Requests $BaseURL $Configuration

}

function Import{
    if($Save){
        # Prompt to save query parameters
        $SaveQuery = Read-Host -Prompt "Save query parameters? [yes/no]"

        $Properties =@{
            "ServerIP" = $ServerIP
            "Key" = $Key
        }
        $Configuration = New-Object psobject -Property $Properties
        if($SaveQuery -eq "yes"){
            Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Query -Value $Query
            Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Duration -Value $Duration
            Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Format -Value $Format
        }
        
        # Save the configuration file
        ConvertTo-Json -InputObject $Configuration | Out-File "$ConfigurationFile"
        return $Configuration
    }
    
    # Load File
    $Loaded = Get-Content $ConfigurationFile -Raw
    $Loaded = ConvertFrom-Json $Loaded
    $Properties =@{
        "ServerIP" = $Loaded.ServerIP
        "Key" = $Loaded.Key
    }
    $Configuration = New-Object psobject -Property $Properties

    # Check for query parameters
    if($Loaded.Query){
        Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Query -Value $Loaded.Query
        Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Duration -Value $Loaded.Duration
        Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Format -Value $Loaded.Format
    }else{
        Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Query -Value $Query
        Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Duration -Value $Duration
        Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Format -Value $Format
    }
    return $Configuration
}

function Requests($BaseURL, $Configuration){
    # Build Headers
    $Headers =@{
        "Gravwell-Token" = $Configuration.Key
        "query" = $Configuration.Query
        "duration" = $Configuration.Duration
        "format" = $Configuration.Format
    }

    # Send request
    Write-Host "Sending request"
    $QueryRequest = Invoke-WebRequest -URI $BaseURL -Headers $Headers -Method POST -SessionVariable querySession
    if($QueryRequest.StatusCode -eq 200){
        Write-Host "Request successful"
        $Response = $QueryRequest | Select-Object -ExpandProperty RawContent
        Write-Host "Writing contents to $Outfile"
        $Response | Out-File $OutFile
    }else{
        Write-Host "Something went wrong with status" $QueryRequest.StatusCode
    }
}

Export-ModuleMember -Function Invoke-GravwellQuery