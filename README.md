# Drill 2

Browser-based multiple choice test learning assistant.


## What is Drill 2?

Drill 2 is a successor to [Pober's Drill System](https://code.google.com/p/drill/), a program built to assist in learning for multiple choice tests.


## Main features

- **Portability.** Looks good on all screen sizes and needs only browser to run. Try it on your mobile!
- **Compatibility.** Old question banks from PBS still work. All Drill 2 files are human-readable in Notepad.
- **Works offline.** Open it once when you're online. From now on it works offline too! No Wi-Fi, no data plan required.
- **Low footprint.** No Java, no extra software. Just a browser.
- **Explanations.** You can add notes and clarifications to every question.
- **Markdown.** Basic text formatting and image embedding.
- **Formulas.** You can use LaTeX to render fancy math formulas.


## How do I use it?

#### Click here: [Drill 2 - public instance](https://gronostajo.github.io/drill2/)

One instance of Drill 2 is publicly available via GitHub pages and always kept up-to-date with major milestones.

Feel free to download or fork the source code and make your own changes. Then you can deploy the application for yourself or for wider audience. (Please mind the [license](https://github.com/gronostajo/drill2/blob/master/LICENSE)!)

In order to enable using your Drill 2 instance as offline app, you need to serve `drill2.appcache` with MIME type `text/cache-manifest`. [Public instance](https://gronostajo.github.io/drill2/) does this.


## Question banks

Questions are loaded from ordinary text files with human-readable structure. You can load those files from your  device's memory. If your browser doesn't support this, you can manually paste file contents.

Files you select and data you paste never leave your computer. Nothing is uploaded to remote servers. Drill 2 works completely within your browser.

Details of file format are described in the [Documentation](https://github.com/gronostajo/drill2/wiki).


## Bugs?

Please report any bugs using the [issue tracker](https://github.com/gronostajo/drill2/issues).

Any contributions, including bug reports, suggestions and bugfixes, are greatly appreciated. Want to help? [Read this first](CONTRIBUTING.md).


## Tech stack

- [AngularJS](https://angularjs.org/)
- [CoffeeScript](http://coffeescript.org/)
- [Bootstrap](https://getbootstrap.com/)
- [gulp](http://gulpjs.com/)
