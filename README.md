<!--
MIT License

Original work Copyright (c) 2020 Dr. Frank Heimes (twitter.com/DrFGHde, www.facebook.com/dr.frank.heimes)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-->

# Reg(shot) Conversion Scripts
The scripts in this directory make `REG` files, used by `RegEdit`, and comparison results produced by [RegShot](https://sourceforge.net/projects/regshot) more readable.

## MakeRegUserfriendly.ps1
This script takes a Windows registry file (`.reg`) and creates a more readable version of it with the
string `.Userfriendly` inserted in its name.

It particularly performs the following conversions:
  * Convert a `dword` value into the notation `0xNNN` and append its decimal value.
  * Use a simple syntax for a `dword` value between 0 and 9 (inclusive).
  * Concatenate all continued lines into a single line.
  * Convert a hex array to a readable unicode strings, provided it contains at least 2 unicode characters and is zero terminated.
  * Convert a non-printable unicode character into its representation `\uNNNN`.

### Examples

  * **Original:** `"AppIDFlags"=dword:00000408`\
    **Converted:** `"AppIDFlags"=0x408 (1032)`

  * **Original:** `"Threading"=dword:00000000`\
    **Converted:** `"Threading"=0`

  * **Original:** `"LaunchPermission"=hex:01,00,14,80,...,00,00,30,00,\` \
                `00,00,02,00,...,00,00,\` \
                `...`\
    **Converted:** `"LaunchPermission"=hex:01,00,14,80,a4,00,00,...`

  * **Original:** `"DllSurrogate"=hex(2):43,00,3a,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\` \
                `00,5c,00,53,00,79,00,73,00,57,00,4f,00,57,00,36,00,34,00,5c,00,70,00,72,00,\` \
                `65,00,76,00,68,00,6f,00,73,00,74,00,2e,00,65,00,78,00,65,00,00,00`\
    **Converted:** `"DllSurrogate"="C:\Windows\SysWOW64\prevhost.exe"`

## MakeRegShotUserfriendly.ps1
This script takes a difference file produced by [RegShot](https://sourceforge.net/projects/regshot)
and performs the same conversions on it as `MakeRegUserfriendly.ps1` does.

Additionally, it filters out irrelevant registry keys and file names that match the pattern
specified in the variable `$IrrelevantPattern`.

## License

Copyright (c) 2020 Dr. Frank Heimes  
See the [License](License.md) file for license rights and limitations (MIT).

## Support

Feature requests, and constructive comments for improvements are highly appreciated.
Since I'm using the scripts myself, I will continue to maintain them.

Feel free to contact me on [Twitter](https://twitter.com/DrFGHde) or [Facebook](https://www.facebook.com/dr.frank.heimes) :sunglasses:
