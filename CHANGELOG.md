### 1.0.39

2025-01-01 13:55

#### FIXED

- Inert_file messing up file extensions

### 1.0.38

2024-08-23 11:20

### 1.0.37

2024-08-23 11:04

#### FIXED

- Attempt to fix installation on Ruby 2.6

### 1.0.36

2024-08-23 11:03

#### FIXED

- Attempt to fix installation on Ruby 2.6

### 1.0.35

2024-08-22 10:14

#### IMPROVED

- Code cleanup
- Cleaner UTF-8 string encoding

### 1.0.34

2024-08-22 10:13

#### IMPROVED

- Code cleanup
- Cleaner UTF-8 string encoding

### 1.0.33

2024-08-22 06:35

#### IMPROVED

- Clean up string encoding in filters

### 1.0.32

2024-07-31 11:12

#### FIXED

- Force UTF-8 encoding on Env and STDIN in command.rb and script.rb

### 1.0.31

2024-07-29 15:40

#### FIXED

- Nil environment variable failure

### 1.0.30

2024-07-29 11:47

### 1.0.29

2024-07-28 09:57

#### NEW

- Increase/decreaseHeaders(count) filter

### 1.0.28

2024-07-27 14:54

#### IMPROVED

- Code cleanup, fix for IRB
- Switch to using #size for character counting
- Begin adding test suite, fixing bugs as found

### 1.0.27

2024-07-24 13:55

#### FIXED

- StripMeta bad regex

### 1.0.26

2024-07-24 13:49

#### FIXED

- Don't recognize YAML closing line as settext header

### 1.0.25

2024-07-22 12:36

#### NEW

- `includes contains [file|path]` testing against included files

#### IMPROVED

- Better env variable handling

#### FIXED

- Inserting comment when YAML exists breaks YAML
- Ensure newline after MMD metadata
- Error in ensure_h1 if no headers exist

### 1.0.24

2024-07-18 11:32

#### IMPROVED

- Use Shellwords.shellsplit/join instead of escaping MARKED_INCLUDES environment variable

### 1.0.23

2024-07-17 15:51

#### FIXED

- Environment variable escaping was hyperactive, only escape includes array

### 1.0.22

2024-07-16 12:30

#### IMPROVED

- When injecting CSS or JS paths, URL encode the path

#### FIXED

- Shell escape environment variables

### 1.0.21

2024-07-10 12:18

#### NEW

- New filter `fixHeaders` will adapt all headlines in the document to be in semantic order

### 1.0.20

2024-07-04 12:18

#### NEW

- The `insertTitle` filter can now take an argument of `true` or a number and will shift the remaining headlines in the document by 1 (or the number given in the argument), allowing for title insertion while only having 1 H1 in the document.

#### IMPROVED

- Ignore self-linking urls in single quotes, just in case they're used in a script line

### 1.0.19

2024-07-02 11:25

#### FIXED

- Bug in creating default config

### 1.0.18

2024-07-02 11:08

#### NEW

- InsertScript or insertCSS arguments that are URLs will be inserted properly

#### FIXED

- When prepending styles/files/titles, always inject AFTER existing metadata (YAML or MMD)

### 1.0.17

2024-07-02 10:27

#### NEW

- AutoLink() filter will self-link bare URLs

### 1.0.16

2024-06-28 12:40

#### NEW

- New insertCSS filter to inject a stylesheet
- YUI compression for injected CSS

### 1.0.15

2024-05-25 11:14

#### NEW

- New filter insertTOC(max, after) to insert a table of contents, optionally with max levels and after (start, *h1, or h2)
- New filter prepend/appendFile(path) to include a file (also pre/appendRaw and pre/appendCode)

### 1.0.14

2024-05-25 06:41

#### NEW

- InsertTitle filter will extract title from metadata or filename and insert an H1 title into the content
- InsertScript will inject a javascript at the end of the content, allows passing multiple scripts separated by comma, and if the path is just a filename, it will look for it in ~/.config/conductor/javascript and insert an absolute path

### 1.0.13

2024-05-24 13:12

#### NEW

- New type of command -- filter: filterName(parameters), allows things like setStyle(github) or replace_all(regex, pattern) instead of having to write scripts for simple things like this. Can be run in sequences.

### 1.0.12

2024-05-01 13:06

#### FIXED

- Attempt to fix encoding error

### 1.0.11

2024-04-29 09:46

#### FIXED

- Reversed symbols when outputting condition matches to STDERR
- Only assume date if it's not part of a filename

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
