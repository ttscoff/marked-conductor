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


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ttscoff/marked-conductor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ttscoff/marked-conductor/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Marked::Conductor project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ttscoff/marked-conductor/blob/main/CODE_OF_CONDUCT.md).
