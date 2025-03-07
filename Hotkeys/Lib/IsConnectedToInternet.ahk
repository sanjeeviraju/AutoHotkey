; Function to check if connected to the internet
IsConnectedToInternet()
{
    ; Ping Google's DNS server
    PingResponse := Ping("8.8.8.8")

    ; Return true if the ping was successful
    Return (PingResponse = 0)
}

; Function to ping an IP address
Ping(IPAddress)
{
    ; Create a WMI object to execute the ping command
    WMIService := ComObjGet("winmgmts:\\.\root\cimv2")
    PingResult := WMIService.ExecQuery("SELECT * FROM Win32_PingStatus WHERE Address='" IPAddress "'")

    ; Get the ping result
    For PingResponse, StatusCode In PingResult
    {
        Return PingResponse.StatusCode
    }
}