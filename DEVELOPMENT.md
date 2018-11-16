# Ephesus::Text Development Notes

## Parser

- #recommend method: |
  supports tab completion of commands, arguments, and keywords

  Examples:
    with an empty string:
      suggests commands
    with a partial command:
      suggests matching commands
    with a command, or a command + argument + "and":
      suggests possible arguments OR keywords
    with a command + keyword, or a command + keyword + kwarg + "and":
      suggests possible kwargs OR keywords
