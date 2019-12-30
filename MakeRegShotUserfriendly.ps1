# Convert a RegShot difference file into a more readable form, Version 1.0.20013.0
#
# MIT License
#
# Original work Copyright (c) 2020 Dr. Frank Heimes (twitter.com/DrFGHde, www.facebook.com/dr.frank.heimes)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

param ([Parameter(Mandatory=$true)] [string]$file)

# Always make sure all variables are defined and all best practices are followed.
Set-StrictMode -version Latest

# Pattern for files, folders, and registry keys considered to be irrelevant
$IrrelevantPattern = '(HKCU|HKLM|HKU).+(\\MRU|MRU\\|\\MUI|MUI\\|\\Bags|RecentDocs|CurrentVersion\\Explorer|Services\\bam|CurrentVersion\\CloudStore|DRIVERS\\DriverDatabase|CurrentVersion\\DeliveryOptimization|Storage\\microsoft.microsoftedge)'

# Convert a hex string from registry to a readable UNICODE string
function UnicodeFromHex([string] $hex)
{
    $ErrorActionPreference = 'SilentlyContinue'

    # Only consider binary data to be a string if it has at least two unicode characters and is zero terminated
    if ($hex.EndsWith('00 00') -and $hex.Length -ge 4)
    {
        ($hex -ireplace '([0-9A-F]{2}) ([0-9A-F]{2})', '0x$2$1' -split ' ' | %{ [char][int64]$_ }) -join ''
    }
    else
    {
        $hex
    }
}

# Concatenate multiple lines of hex codes into a single line
filter RemoveContinuation
{
    $_ -ireplace '\r\n([0-9A-F]?[ ]?([0-9A-F]{2} )+([0-9A-F]{2}))', '$1'
}

# Split input into array of lines
filter SplitLines
{
    $_ -split '\r\n'
}

# Return only relevant registry keys and files
filter Relevant
{
    $_ | ? { $_ -notmatch $IrrelevantPattern }
}

# Convert DWord entries into hex value and separate int value in braces
filter ConvertDWord
{
    [regex]::Replace($_, ': 0x([0-9A-Fa-f]+)$', {
        param($match)
        [int64]$value = '0x' + $match.Groups[1].Value; "$(if ($value -lt 10) { '={0}' } else { '=0x{0:X} ({0})' })" -f $value
    })
}

# Make the entire line readable by converting hex sub strings
filter ConvertHexCodes
{
    [regex]::Replace($_, '(([0-9A-Fa-f]{2} )+([0-9A-Fa-f]{2}))', {param($match) "$(UnicodeFromHex $match.Groups[1].Value)"})
}

# Write non-printable characters as hex codes again
filter MakePrintable
{
    [regex]::Replace($_, '([\u0000-\u001F\u00FF-\uFFFF])', {param($match) "$('\u{0:X4}' -f [int64][char]$match.Groups[1].Value)"})
}

$file = Get-ChildItem $file

# Note: The -Encoding flag may need to be adjusted if the input file is in another encoding
Get-Content -Raw -Encoding Unicode ($file.FullName) | RemoveContinuation | SplitLines | ConvertDWord | Relevant | ConvertHexCodes | MakePrintable |`
Set-Content -Encoding UTF8 ([io.path]::ChangeExtension($file, '.Userfriendly' + $file.Extension))
