### 1.0.6

2024-04-26 11:15

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
