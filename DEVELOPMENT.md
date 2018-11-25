# Ephesus::Text Development Notes

## Commands

- "help"
- "what can I do"

## Console

- handles text input/output
- actual IO operations delegated to an Adapter
  - Adapters::Mock
  - Adapters::Readline
- process flow:
  1. user? types an input string
  2. Adapter captures text input
  3. Adapter calls Console#input
  4. Console calls #process_input
    A. input is passed to Parser
    B. parsed command/arguments are passed to Session#execute_command
  5. Console result or error handler(s) is/are called with command result.
  6. Handler calls Console#output or #error.
  7. Console delegates output to Adapter#output or #error.

### Adapter

- initialized with Console instance
- has #output, #error methods
- on text input, calls Console#input

### Handlers

- ::handle_exception

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
