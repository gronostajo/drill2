# Contributing to Drill 2

So you want to contribute? That's great! This document contains guidelines for everyone who's eager to help.


## Reporting issues

Here's a list of things to check before sending in a bug report:

- Make sure the issue [hasn't been reported yet](https://github.com/gronostajo/drill2/issues).
- Make sure the title describes actual problem. *"Explanations don't show up"* is good. *"Bug in question #32"* is bad.
- When reporting issue in a specific question bank, include it in your bug report. Try to prepare a [Minimal, Complete, Verifiable example](https://stackoverflow.com/help/mcve).
- Screenshots may be helpful. Just hit `Ctrl`+`V` to upload them.
- Before posting a part of question bank make sure you really want it floating on the public web. Consider using [Lorem ipsum](https://generator.lorem-ipsum.info/) instead of real text.


## Proposing enhancements

Unfortunately I'm not actively working on Drill 2 anymore. Feel free to develop new features yourself though!


## Code contributions

You can [fork Drill 2](https://github.com/gronostajo/drill2/fork) and create a pull request when you're ready. I'll review your code and consider integrating it in the main codebase.

This project uses a vintage tech stack which isn't relevant anymore. If you're brave enough to modernize it, [check out issue #39](https://github.com/gronostajo/drill2/issues/39).

Drill 2 uses *bower* and *gulp*.

- [bower](http://bower.io) is a package manager for web apps
- [gulp](http://gulpjs.com/) is a build automation tool

Quick start:

Honestly, don't bother with trying to make it work on modern platforms. Use Visual Studio Code's dev containers feature. The repo comes with a dev container where everything should just work.

1. Clone your fork:

        git clone git@github.com:YourUserName/drill2.git

0. Install build tools:

        npm install

0. Install project dependencies:

        bower install

Then use following commands each time you want to build the app:

- `gulp build` - Builds Drill 2 with appcache disabled and no optimizations. Debugging-friendly.
- `gulp build --production` - Builds a production-ready instance of Drill 2 with full appcache support.

Output files are created in the `build` folder.

Tips:

- Don't add new files to the `index.html` header, appcache manifest or Karma configuration - they are automatically updated by `gulp` when building app.
- If you're getting weird error messages, you may have to install new packages. Just run `npm install && bower install` and have a tea.
