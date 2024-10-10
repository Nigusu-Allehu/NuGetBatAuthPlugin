@echo off
setlocal EnableDelayedExpansion

echo Initializing variables and setting up input/output files

rem Define input and output files
set "inputFile=input.json"
set "outputFile=output.txt"

rem Clear the output file
echo Clearing the output file: %outputFile% > "%outputFile%"

rem Read the input file and aggregate all lines into one line
echo Reading the input file and aggregating into one line: %inputFile%
set "jsonLine="
for /f "delims=" %%a in (%inputFile%) do set "jsonLine=!jsonLine!%%a"

echo JSON line read: !jsonLine!
set quote="
set comma=,
set colon=:
set openCurlyBracket={
set closeCurlyBracket=}
set comma=,
set key=
set value=
set onKeySearch=true
set onValueSearch=false
set enteredQuotes=false

rem Loop through each character in the JSON line using the provided method
echo Starting character processing loop
set pos=0
:NextChar
    set index=%pos%
    set char=!jsonLine:~%pos%,1!
    ::echo Processing character %index%: !char!
    ::echo key: !key!

    if %onKeySearch%==true (
        if %enteredQuotes%==true (
            ::echo inside quotes
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
            ::echo inside quotes
            if !char!==!quote! (
                set onKeySearch=true
                set onValueSearch=true
                set enteredQuotes=false
                echo key: !key!
                echo value: !value!
                set key=
                set value=
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

:endLoop
echo Character processing loop completed

echo Outputting the result to the console
type "%outputFile%"

endlocal