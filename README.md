
[![RubyGems.org](https://img.shields.io/gem/v/marked-conductor)](https://rubygems.org/gems/marked-conductor)

# Marked Conductor

A "train conductor" for [Marked 2](https://marked2app.com). Conductor can be set up as a Custom Preprocessor or Custom Processor for Marked, and can run different commands and scripts based on conditions in a YAML configuration file, allowing you to have multiple processors that run based on predicates.

## Installation

    $ gem install marked-conductor

If you run into errors, try running with the `--user-install` flag:

    $ gem install --user-install marked-conductor

> I've noticed lately with `asdf` that I have to run `asdf reshim` after installing gems containing binaries.

If you use Homebrew, you can run 

    $ brew gem install marked-conductor

## Usage

To use Conductor, you need to set up a configuration file in `~/.config/conductor/tracks.yaml`. Run `conductor` once to create the directory and an empty configuration. See [Configuration](#configuration) below for details on setting up your "tracks." 

Once configured, you can set up conductor as a Custom Processor in Marked. Run `which conductor | pbcopy` to get the full path to the binary and copy it, then open <b>Marked Preferences > Advanced</b> and select either Custom Processor or Custom Preprocessor (or both) and paste into the <b>Path:</b> field. You can select <i>Automatically enable for new windows</i> to have the processor enabled by default when opening documents.


![Marked preferences](images/preferences.jpg)

Conductor requires that it be run from Marked 2, and won't function on the command line. This is because Marked defines special environment variables that can be used in scripts, and these won't exist when running from your shell. If you want to be able to test Conductor from the command line, see [Testing](#testing).

## Configuration

Configuration is done in a YAML file located at `~/.config/conductor/tracks.yaml`. Run `conductor` from the command line to generate the necessary directories and sample config file if it doesn't already exist.

The top level key in the YAML file is `tracks:`. This is an array of hashes, each hash containing a `condition` and either a `script` or `command` key.

A simple config would look like:

```yaml
tracks:
  - condition: yaml includes comments
    script: blog-processor
  - condition: any
    command: echo 'NOCUSTOM'
```

This would run a script at `~/.config/conductor/scripts/blog-processor` if there was YAML present in the document and it included a key called `comments`. If not, the `condition: any` would echo `NOCUSTOM` to Marked, indicating it should skip any Custom Processor. If no condition is met, NOCUSTOM is automatically sent, so this particular example is redundant. In practice you would include a catchall processor to act as the default if no prior conditions were met.

Instead of a `script` or `command`, a track can contain another `tracks` key, in which case the parent condition will branch and it will cycle through the tracks contained in the `tracks` key for the hash. `tracks` keys can be repeatedly nested to create AND conditions.
 
For example, the following functions the same as `condition: phase is pre AND tree contains .obsidian AND (extension is md or extension is markdown)`:

```yaml
tracks:
  - condition: phase is pre
    tracks:
    - condition: tree contains .obsidian
      tracks:
      - condition: extension is md
        command: obsidian-md-filter
      - condition: extension is markdown
        command: obsidian-md-filter
```

### Conditions

Available conditions are:

- `extension` (or `ext`): This will test the extension of the file, e.g. `ext is md` or `ext contains task`
- `tree contains ...`: This will test whether a given file or directory exists in any of the parent folders of the current file, starting with the current directory of the file. Example: `tree contains .obsidian` would test whether there was an `.obsidian` directory in any of the directories above the file (indicating it's within an Obsidian vault)
- `path`: This tests just the path to the file itself, allowing conditions like `path contains _drafts` or `path does not contain _posts`.
- `phase`: Tests whether Marked is in Preprocessor or Processor phase, allowing conditions like `phase is preprocess` or `phase is process` (which can be shortened to `pre` and `pro`).
- `text`: This tests for any string match within the text of the document being processed. This can be used with operators `starts with`, `ends with`, or `contains`, e.g. `text contains @taskpaper` or `text does not contain <!--more-->`. 
    - If the test value is surrounded by forward slashes, it will be treated as a regular expression. Regexes are always flagged as case insensitive. Use it like `text contains /@\w+/`.
- `yaml`, `headers`, or `frontmatter` will test for YAML headers. If a `yaml:KEY` is defined, a specific YAML key will be tested for. If a value is defined with an operator, it will be tested against the value key.
    - `yaml` tests for the presence of YAML frontmatter.
    - `yaml:comments` tests for the presence of a `comments` key.
    - `yaml:comments is true` tests whether `comments: true` exists.
    - `yaml:tags contains appreview` will test whether the tags array contains `appreview`.
    - If the YAML key is a date, it can be tested against with `before`, `after`, and `is`, and the value can be a natural language date, e.g. `yaml:date is after may 3, 2024`
    - If both the YAML key value and the test value are numbers, you can use operators `greater than` (`>`), `less than` (`<`), `equal`/`is` (`=`/`==`), and `is not equal`/`not equals` (`!=`/`!==`). Numbers will be interpreted as floats.
    - If the YAML value is a boolean, you can test with `is true` or `is not true` (or `is false`)
- The following keywords act as a catchall and can be used as the last track in the config to act on any documents that aren't matched by preceding rules:
    - `any`
    - `else`
    - `all`
    - `true`
    - `catchall`

Available comparison operators are:

- `is` or `equals` (negate with `is not` or `does not equal`) tests for equality on strings, numbers, or dates
- `contains` or `includes` (negate with `does not contain`) tests on strings or array values
- `begins with` (or `starts with`) or `ends with` (negate with `does not begin with`) tests on strings
- `greater than` or `less than` (tests on numbers or dates)

Conditions can be combined with AND or OR (must be uppercase) and simple parenthetical operations will work (parenthesis can not be nested). A boolean condition would look like `path contains _posts AND extension is md` or `(tree includes .obsidian AND extension is todo) OR extension is taskpaper`.

### Actions

The action can be either `script` or `command`. 

Scripts are located in `~/.config/conductor/scripts/` and should be executable files that take input on STDIN (unless `$file` is specified in the `script` definition). If a script is defined starting with `~` or `/`, that will be interpreted as a full path to an alternate location.

Commands are interpreted as shell commands. If a command exists in the `$PATH`, a full path will automatically be determined, so a command can be as simple as just `pandoc`. Add any arguments needed after the command.

Using `$file` as an argument to a script or command will bypass processing of STDIN input, and instead use the value of $MARKED_PATH to read the contents of the specified file.

## Custom Processors

All of the [capabilities and requirements](https://marked2app.com/help/Custom_Processor) of a Custom Processor script or command still apply, and all of the [environment variables that Marked sets](https://marked2app.com/help/Custom_Processor#environmentvariables) are still available. You just no longer have to have one huge script that forks on the various environment variables and you don't have to write your own tests for handling different scenarios.

A script run by Conductor already knows it has the right type of file with the expected data and path, so your script can focus on just processing one file type. It's recommended to separate all of that logic you may already have written out into separate scripts and let Conductor handle the forking based on various criteria.

## Tips

- Config file must be valid YAML. Any value containing colons, brackets, or other special characters should be quoted, e.g. (`condition: "text contains my:text"`)
- You can see what condition matched in Marked by opening <b>Help->Show Custom Processor Log</b> and checking the STDERR output.
- To run [a custom processor for Bear](https://brettterpstra.com/2023/10/08/marked-and-bear/), use the condition `"text contains <!-- source: bear.app -->"`
- To run a custom processor for Obsidian, use the condition `tree contains .obsidian`

## Testing

In order to test from the command line, you'll need certain environment variables set. This can be done by exporting the following variables with your own definitions, or by running conductor with all of the variables preceding the command, e.g. `$ MARKED_ORIGIN=/path/to/markdown_file.md [...] conductor`.

The following need to be defined. Some can be left as empty or to defaults, such as `MARKED_INCLUDES` and `MARKED_OUTLINE`, but all need to be set to something.

```
HOME=$HOME
MARKED_CSS_PATH="" # The path to CSS, can be empty
MARKED_EXT="md" # The extension of the current file in Marked, set as needed for testing
MARKED_INCLUDES="" # Files included in the document, can be empty
MARKED_ORIGIN="/Users/ttscoff/notes/" # Base directory for the file being tested
MARKED_PATH="/Users/ttscoff/notes/markdown_file.md" # Full path to Markdown file
MARKED_PHASE="PREPROCESS" # either "PROCESS" or "PREPROCESS"
OUTLINE="none" # Outline mode, can be "none"
PATH=$PATH # The system $PATH variable
```

Further, input on STDIN is required, unless the script/command being matched contains `$file`, in which case $MARKED_PATH will be read and operated on. For the purpose of testing, you can use `echo` or `cat FILE` and pipe to conductor, e.g. `echo "TESTING" | conductor`.

To test which conditions are being met, you can just set the `command:` for a track to `echo "meaningful message"`, where the message is something that indicates which condition(s) have passed.



## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/ttscoff/marked-conductor>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ttscoff/marked-conductor/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Marked::Conductor project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ttscoff/marked-conductor/blob/main/CODE_OF_CONDUCT.md).

