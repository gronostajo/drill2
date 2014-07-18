# Drill 2

Browser-based multiple choice test learning assistant.

## What is Drill 2?

Drill 2 is a successor to [Pober's Drill System](https://code.google.com/p/drill/), a program built to assist in learning for multiple choice tests. The idea behind Drill 2 was to keep all advantages of original PDS, while making it compatible with a wide range of devices.

## Main features

- **Portability.** Drill 2 is built with mobile devices in mind. It's browser-based and responsive, so it runs everywhere and looks good on any screen size, from low-end smartphone screens to full-sized computer displays.
- **Compatibility.** It's using the same text file format that PBS used. Question banks are human-readable and can be edited in any text editor without hassle.
- **Low footprint.** Drill 2 doesn't require Java VM or any additional software, except for a web browser.
- **Markdown support.** You can apply basic text formatting to your questions. Image embedding is supported too.
- **Explainations.** Sometimes questions need explainations why some answers are correct and other ones aren't, now you can add them.
- **Neat formulas.** You can use LaTeX to render fancy math formulas in user's browser.

## How do I use it?

One instance of Drill 2 is [publicly available](https://gronostajo.github.io/drill2/) via GitHub pages and always kept up-to-date. Any changes to the source are instantly available for anyone.

Feel free to download or fork the source code and make your own changes. Then you can deploy the application for yourself or for wider audience. (Please mind the [license](https://github.com/gronostajo/drill2/blob/master/LICENSE)!)

In order to enable using your Drill 2 instance as offline app, you need to serve `drill2.appcache` with MIME type `text/cache-manifest`.

## Question banks

Questions are loaded from ordinary text files with human-readable structure. You can load those files from your computer's hard disk or device's memory, or, if your browser doesn't support File API, you can manually paste file contents into Drill 2.

Files you select and data you paste never leave your computer. Nothing is uploaded to remote servers. Drill 2 works completely within your browser.

Details of file format are described in the [Documentation](https://github.com/gronostajo/drill2/wiki).

## Bugs?

Please report any bugs using the [issue tracker](https://github.com/gronostajo/drill2/issues).

Any contributions, including bug reports, suggestions and bugfixes, are greatly appreciated.

## Tech stack

- **Bootstrap** for layout
- **jQuery** for Bootstrap plugins
- **AngularJS** for application logic

## Who built it?

Hi, I'm Krzysiek. I'm a CS student and not-yet-professional web developer. In my free time I build [things](http://avensome.net/projekty) and help people on StackExchange, occasionally asking questions myself.

![gronostaj's StackExchange flair](https://stackexchange.com/users/flair/2190908.png)
