# Drill 2

Browser-based multiple choice test learning assistant.

### [Use it here](https://gronostajo.github.io/drill2/)


## Main features

- **Portability.** Looks good on all screen sizes and needs only browser to run. Try it on your mobile!
- **Compatibility.** Old question banks from Pober's Drill System still work. All Drill 2 files are human-readable text files.
- **Works offline.** Open it once when you're online. From now on it works offline too! No Wi-Fi, no data plan required.
- **Low footprint.** No Java, no extra software. Just a browser.
- **Explanations.** You can add notes and clarifications to every question.
- **Markdown.** Basic text formatting and image embedding.
- **Formulas.** You can use LaTeX to render fancy math formulas.


## How do I use it?

One [instance of Drill 2](https://gronostajo.github.io/drill2/) is publicly available via GitHub pages and always kept up-to-date with major milestones. There's also a [bleeding-edge version](https://gronostajo.github.io/drill2/develop/) deployed automatically when the [`develop` branch](https://github.com/gronostajo/drill2/tree/develop) is updated.

Feel free to download or fork the source code and make your own changes. Then you can deploy the application for yourself or for wider audience. (Please mind the [license](LICENSE)!)

In order to enable using your Drill 2 instance as offline app, you need to serve `drill2.appcache` with MIME type `text/cache-manifest`.


## Question banks

Questions are loaded from ordinary text files with human-readable structure. You can load those files from your device's storage. If your browser doesn't support this, you can manually paste file contents.

Files you select and data you paste never leave your computer. Nothing is uploaded to remote servers. Drill 2 works entirely within your browser.

Details of file format are described in the [Documentation](https://github.com/gronostajo/drill2/wiki).


## Bugs?

Please report any bugs using the [issue tracker](https://github.com/gronostajo/drill2/issues).

Any contributions, including bug reports, suggestions and bugfixes, are greatly appreciated. Want to help? [Read this first](CONTRIBUTING.md).


## Honorable mentions

I'd like to thank everyone who contributed to this codebase. Your effort is much appreciated.

Drill 2 is a spiritual successor to [Pober's Drill System](https://code.google.com/p/drill/).
