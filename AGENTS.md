## Instructions for LLMs

1. Make sure you load the file `docs/llms.md` and read it all. Never skip reading that file for any task.

## Test Coverage

This project requires 100% line and branch coverage through SimpleCov.

### First check

Achieve 100% line and branch coverage. Use following commands:

```
bundle exec rake test
```

### When you find coverage issue

Decide which bucket it falls into:

- **A) The code does too much** for what the tests ask for. The
  coverage issue reveals behavior that no test requires. The
  fix is to simplify the implementation.
- **B) A test is missing.** The behavior is intentional but no test
  observes it. The fix is to add a test.

Decide between A) and B) before changing anything. If unsure, ask
the user.

### Before finishing work

Always run and make sure that there are no issues reported.

```sh
bin/ci
```

Confirm that SimpleCov reports 100% line and branch coverage with no per-file failures.

## Code Smells

This project requires zero Reek offenses.

- Never disable a detector, weaken a threshold, exclude a path, or suppress an offense without explicit user approval.
- Never add class-wide exclusions to make a folder pass.
- Never add inline `:reek:` suppression comments to Ruby files.
- Keep all user-approved Reek exceptions in `.reek.yml`.
- Give approved exceptions the narrowest available scope and add a short YAML comment explaining why.
- If an offense appears incorrect, conflicts with Rails conventions, or would require a harmful refactor, stop and ask the user. Include:
  - The exact offense and location.
  - Why it may not apply.
  - The refactoring options.
  - The proposed `.reek.yml` exception, if appropriate.

### Acceptance criteria

Work is not finished, until `reek .` doesn't returns any offenses.
