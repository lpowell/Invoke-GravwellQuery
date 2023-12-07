# Invoke-GravwellQuery
Invoke-GravwellQuery is a PowerShell module for use with the Gravwell search API. It allows API administrators to save and retrieve Gravwell queries. 

# Configuration
Parameters can be saved into a JSON file through the command line or through pre-configured JSON profiles. 
JSON profiles must be in the following format:
```
{
  "ServerIP": "<IP>:<port>",
  "Key": "<key>",
  "Query": "<query>",
  "Duration": "<hours>h",
  "Format": "<format>"
}
```
ServerIP and Key are required. Query parameters can be saved into a profile or loaded during invocation. 

# Examples

Execute a query and save the parameters into a default profile.
```
Invoke-GravwellQuery -ServerIP 127.0.0.1 -Key "<key>" -Query "tag=windows" -Duration "24h" -Format "csv" -Save -ConfigurationFile "defaultprofile.json" -Outfile results.csv
```
Load a saved profile
```
Invoke-GravwelQuery -Load -ConfigurationFile default.json -Outfile results.csv
```
Load a saved profile with a custom query
```
Invoke-GravwellQuery -Load -ConfigurationFile default.json -Query "tag=windows" -Duration 12h -Format "csv" -Outfile results.csv
```
