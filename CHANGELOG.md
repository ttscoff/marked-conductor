### 1.0.10

2024-04-28 14:05

#### IMPROVED

- Return NOCUSTOM if changes are not made by scripts/commands, even though condition was matched
- Use YAML.load instead of .safe_load to allow more flexibility
- Trap errors reading YAML and fail gracefully

#### FIXED

- Encoding errors on string methods

### 1.0.9

2024-04-27 16:00

#### NEW

- Test for pandoc metadata (%%) with `is pandoc` or `is not pandoc`

#### FIXED

- Filename comparison not working

### 1.0.8

2024-04-27 14:01

#### NEW

- Add sequence: key to allow running a series of scripts/commands, each piping to the next
- Add `continue: true` for tracks to allow processing to continue after a script/command is successful
- `filename` key for comparing to just filename (instead of full
- Add `is a` tests for `number`, `integer`, and `float`
- Tracks in YAML config can have a title key that will be shown in STDERR 'Conditions met:' output
- Add `does not contain` handling for string and metadata comparisons

#### IMPROVED

- Allow `has yaml` or `has meta` (MultiMarkdown) as conditions

#### FIXED

- Use STDIN instead of reading file for conditionals
- String tests read STDIN input, not reading the file itself, allowing for piping between multiple scripts

### 1.0.7

2024-04-26 11:53

#### NEW

- Added test for MMD metadata, either for presence of meta or for specific keys or key values

#### FIXED

- Remove some debugging garbage

### 1.0.6

2024-04-26 11:17

#### FIXED

- Always wait for STDIN or Marked will crash. Still possible to use $file in script/command values
- More string encoding fixes
- "path contains" was returning $PATH instead of the filepath

### 1.0.5

2024-04-25 17:00

#### FIXED

- First-run config creating directory instead of file
- Frozen string/encoding issue on string comparisons

### 1.0.3

2024-04-25 14:32

#### FIXED

- YAML true/false testing

### 1.0.2

2024-04-25 14:15

#### CHANGED

- Prepped for gem release

#### FIXED

- Encoding issue affecting Shellwords.escape

### 1.0.0

2024-04-25 10:51

#### NEW

- 1.0 release

### 0.1.0

- Initial release
