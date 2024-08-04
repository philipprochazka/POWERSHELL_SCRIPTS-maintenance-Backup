# Define the PSReadline key handlers
function Register-CamelCaseNavigation {
    $null = Set-PSReadlineKeyHandler -Key ctrl+rightarrow -ScriptBlock {
        $cursor = $null
        $line = $null
        $direction = $null

        $tokens = [System.Management.Automation.PSParser]::Tokenize($null, $null, $null, $null, $null)

        if ($tokens.Count -gt 0) {
            $cursor = $tokens[0].Start
            $line = $tokens[0].Content
            $direction = 1
        }

        while ($cursor -ge 0 -and $cursor -lt $line.Length) {
            $char = $line[$cursor]

            if ($char -cmatch '\p{Lu}') {
                break
            }

            $cursor += $direction
        }

        if ($cursor -ge 0 -and $cursor -lt $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)
        }
    }

    $null = Set-PSReadlineKeyHandler -Key ctrl+leftarrow -ScriptBlock {
        $cursor = $null
        $line = $null
        $direction = $null

        $tokens = [System.Management.Automation.PSParser]::Tokenize($null, $null, $null, $null, $null)

        if ($tokens.Count -gt 0) {
            $cursor = $tokens[0].Start
            $line = $tokens[0].Content
            $direction = -1
        }

        while ($cursor -gt 0 -and $cursor -le $line.Length) {
            $char = $line[$cursor - 1]

            if ($char -cmatch '\p{Lu}') {
                break
            }

            $cursor += $direction
        }

        if ($cursor -gt 0 -and $cursor -le $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)
        }
    }
}

# Register the PSReadline key handlers
Register-CamelCaseNavigation
