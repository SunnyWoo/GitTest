on run argv
  tell application "Adobe Illustrator"
    do javascript "#include " & first item of argv & "; main(arguments);" with arguments argv
  end tell
end run
