# Ephesus::Text Development Notes

## Commands

### Help

- result value is hash
  - if { string: some string }, output directly
- topics
  - e.g. "exiting the game", "entering commands", "command arguments"
  - if no argument given, result value is empty hash
    - subclass can replace with { string: default help text }
  - "help topics" lists available topics, returns { topics: array of topics }
  - "help TOPIC" returns { string: topic info }
  - "help COMMAND" returns { command: command properties }
  - coded into Help subclass or loaded from data

## Utils

- refactor Utils::Format::format_command_help to CommandFormatter.
  - e.g. CommandFormatter.new(properties).help_text
