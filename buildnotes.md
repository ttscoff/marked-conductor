template: git, gem, project
project: conductor
readme: src/_README.md

# marked-conductor

Train conductor for Marked

## File Structure

Standard gem structure.

## Deploy

You no longer need to manually bump the version, it will be incremented when this task runs.

```run Update Changelog
#!/bin/bash

changelog -u
```

@include(project:Update GitHub README)

```run Commit with changelog
#!/bin/bash

changelog | git commit -a -F -
git pull
git push
```

@include(gem:Release Gem) Release Gem
@include(project:Update Blog Project) Update Blog Project
@run(rake bump[patch]) Bump Version

@run(git commit -am 'Version bump')

@after
Don't forget to publish the website!
@end
