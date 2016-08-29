# Contributing to Drill 2

So you want to contribute? That's great! This document contains guidelines for everyone who's eager to help.


## Reporting issues

Drill 2 is in beta. *Bugs happen*. Please report any issues you may spot.

Here's a list of things to check before sending in a bug report:

- Make sure the issue [hasn't been reported yet](https://github.com/gronostajo/drill2/issues).
- Make sure the title describes actual problem. *"Explanations don't show up"* is good. *"Bug in question #32"* is bad.
- When reporting issue in a specific question bank, include it in your bug report. Try to prepare a [Minimal, Complete, Verifiable example](https://stackoverflow.com/help/mcve).
- Screenshots may be helpful. Just hit `Ctrl`+`V` to upload them.
- Before posting a part of question bank make sure you really want it floating in the public web. Consider using [Lorem ipsum](http://generator.lorem-ipsum.info/) instead of real text.


## Proposing enhancements

I'm always open for new ideas. If you know how to enhance Drill 2 or need a feature that's currently missing, feel free to post your idea as an issue.

Try to be as clear as possible. You can include a sketch of the new feature if you want to.


## Code contributions

You want to patch a nasty bug or develop a new feature? That's great! [Fork Drill 2](https://github.com/gronostajo/drill2/fork) to create a copy you can work on. Commit your changes and create a pull request when you're ready. I'll review your code and consider integrating it in the main codebase.

Drill 2 uses *bower* and *gulp*.

- [bower](http://bower.io) is a package manager for web apps
- [gulp](http://gulpjs.com/) is a build automation tool

Don't be scared, using them is pretty straightforward. You just have to issue a few commands *once* and then remember two of them.

### Development quick start

1. Install [node.js](https://nodejs.org/en/). (required to run bower and gulp)

0. Clone your fork:

        git clone git@github.com:YourUserName/drill2.git

0. Install build tools:

        npm install

0. Initialize project:

        gulp init

Then use following commands each time you want to build the app:

- `gulp build-dev` - Builds Drill 2 with appcache disabled. Useful if you don't want to clear appcache or double-refresh every time you change something.
- `gulp build` - Builds a production-ready instance of Drill 2 with full appcache support.

Output files are created in the `build` folder.

If you're using a JetBrains IDE (IntelliJ IDEA, WebStorm, PhpStorm), you can add these gulp tasks as run configurations.

### Tips

- Don't add new files to `index.html` header, appcache manifest or Karma configuration - they are automatically updated by `gulp` when building app.
- If you're getting weird error messages, you may have to install new packages. Just run `npm install && bower install` and have a tea.
