# This script will require the Web Application and permissions setup in Azure Active Directory
$ClientID       = "CLIENT ID HERE"             # Should be a ~35 character string insert your info here
$ClientSecret   = "CLIENT SECRET HERE"         # Should be a ~44 character string insert your info here
$loginURL       = "https://login.windows.net"
$tenantdomain   = "TENANT DOMAIN HERE"            # For example, contoso.onmicrosoft.com

# Get an Oauth 2 access token based on client id, secret and tenant domain
$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body

$XDaysAgo = "{0:s}" -f (get-date).AddDays(- **DAYS GO HERE**) + "Z" #For example, last 7 days would be "...AddDays(-7)"
# or, AddMinutes(-5)

Write-Output $XDaysAgo

if ($oauth.access_token -ne $null) {
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

    $url = "https://graph.windows.net/$tenantdomain/reports/b2cUserJourneyEvents?api-version=beta&\`$filter=eventTime gt $XDaysAgo"

    $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)

    $csvCon = ($myReport.Content | ConvertFrom-Json).value | ConvertTo-Csv -NoTypeInformation
    Write-Output $csvCon
    $csvCon | Out-File -FilePath b2cUserJourneyEvents.csv -Encoding ASCII -Force
} else {
    Write-Host "ERROR: No Access Token"
}
