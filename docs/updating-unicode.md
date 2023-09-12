## Updating the Unicode emoji

If we're missing a Unicode emoji, please check if it's been added to our upstream data source, [iamcal/emoji-data](https://github.com/iamcal/emoji-data), and if so, either poke us to update it, or follow these instructions to construct a PR:

1. Clone this repo
1. Make sure you have Ruby, Bundler, Node and Yarn installed
1. Run `bundle install && yarn && yarn add emoji-datasource-apple && rake sync && rake verify`
1. If that all works without errors, copy the output of running `rake default` and paste it into the main Readme, replacing the contents of the "Emoji Reference" section
1. Commit, push, and open a PR!
