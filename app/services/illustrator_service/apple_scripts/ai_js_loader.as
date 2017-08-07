on run argv
  tell application "Adobe Illustrator"
    do javascript "#include " & first item of argv
  end tell
end run
