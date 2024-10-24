@echo off
setlocal EnableDelayedExpansion

:InputLoop
set /p jsonLine=

set debugLogPath=N:\Nigusu\NuGetBatAuthPlugin\debug.log
echo JSON line read: !jsonLine! >> %debugLogPath%
set quote="
set comma=,
set colon=:
set openCurlyBracket={
set closeCurlyBracket=}
set key=
set value=
set dot=.
set onKeySearch=true
set onValueSearch=false
set enteredQuotes=false

echo Starting character processing loop >> %debugLogPath%
set pos=0
:NextChar
    echo Current position: %pos% >> %debugLogPath%
    set index=%pos%
    set char=!jsonLine:~%pos%,1!
    echo Processing character: !char! >> %debugLogPath%
    if "!char!"=="" goto endLoop
    if %onKeySearch%==true (
        if %enteredQuotes%==true (
            if !char!==!quote! (
                set onKeySearch=false
                set onValueSearch=true
                set enteredQuotes=false
            ) else (
                set key=!key!!char!
            )
        ) else if !char!==!quote! (
            set enteredQuotes=true
        )
    ) else if %onValueSearch%==true (
        if %enteredQuotes%==true (
            if !char!==!quote! (
                set onKeySearch=true
                set onValueSearch=true
                set enteredQuotes=false
                set "!key!=!value!"
                set value=
                set /a pos=pos+1
                goto ClearKey
            ) else (
                set value=!value!!char!
            )
        ) else if !char!==!quote! (
            set enteredQuotes=true
        ) else if !char!==!openCurlyBracket! (
            set onKeySearch=true
            set onValueSearch=false
            set key=!key!.
        )
    ) else (
        echo neither
    )
    set /a pos=pos+1
    if "!jsonLine:~%pos%,1!" NEQ "" goto NextChar

:ClearKey
    if "!key!"=="" (
        goto NextChar
    )
    set lastChar=!key:~-1!
    if !lastChar!==!dot! (
        goto NextChar
    ) else (
        set  key=!key:~0,-1!
        goto ClearKey
    )
    goto NextChar


:endLoop
if "!RequestId!" == "" (
    goto InputLoop
) else (
    set reponseJsonString={"RequestId":"!RequestId!","Type":"Response","Method":"Handshake","Payload":{"ProtocolVersion":"2.0.0","ResponseCode":0}}
    set requestJsonString={"RequestId":"!RequestId!","Type":"Request","Method":"Handshake","Payload":{"ProtocolVersion":"2.0.0","MinimumProtocolVersion":"1.0.0"}}
    echo !reponseJsonString!
    echo !requestJsonString!
    echo !jsonString! >> %debugLogPath%
)
goto InputLoop
