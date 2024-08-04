
If you like the features of z but find its limitation of listing only folders to be a drawback, you might consider using a combination of tools to achieve the desired functionality. You can continue using z for its strengths, such as fuzzy searching and frequent directory tracking, and then use another tool like PowerShell's Get-ChildItem when you specifically need a more comprehensive listing of both files and folders.

For example, you can create a PowerShell function or alias that combines the strengths of both tools:

powershell
Copy code
    function ZGet {
        param (
            [switch]$ListFiles,
            [switch]$Verbose
            [switch]$foo
            [switch]$foobar
        )

        if ($ListFiles) {
            Get-ChildItem
        }
        if ($foo) {
            Get-ChildItem
        }
        elseif ($foobar) {
            z -foobar
        }
        [
        else {
            z 
        }

        if ($Verbose) {
            Write-Host "Verbose mode is enabled."
        }
    }