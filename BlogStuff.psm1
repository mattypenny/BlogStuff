foreach ($F in $(get-childitem  $PsScriptRoot/functions/*.ps1)) {
    . $F.fullname
}
