# Drill 2

Browser-based multiple choice test learning assistant.

## What is Drill 2?

Drill 2 is a successor to [Pober's Drill System](https://code.google.com/p/drill/), a program built to assist in learning for multiple choice tests. The idea behind Drill 2 was to keep all advantages of original PDS, while making it compatible with a wide range of devices.

## Main features

- **Portability.** Drill 2 is built with mobile devices in mind. It's browser-based and responsive, so it runs everywhere and looks good on any screen size, from low-end smartphone screens to full-sized computer displays.
- **Compatibility.** It's using the same text file format that PBS used. Question banks are human-readable and can be edited in any text editor without hassle.
- **Low footprint.** Drill 2 doesn't require Java VM or any additional software, except for a web browser.
- **Markdown support.** You can apply basic text formatting to your questions. Image embedding is supported too.

## How do I use it?

One instance of Drill 2 is [publicly available](https://gronostajo.github.io/drill2/) via GitHub pages and always kept up-to-date. Any changes to the source are instantly available for anyone.

Feel free to download or fork the source code and make your own changes. Then you can deploy the application for yourself or for wider audience. (Please mind the [license](https://github.com/gronostajo/drill2/blob/master/LICENSE)!)

In order to enable using your Drill 2 instance as offline app, you need to serve `drill2.appcache` with MIME type `text/cache-manifest`.

## Question banks

Questions are loaded from ordinary text files with human-readable structure. You can load those files from your computer's hard disk or device's memory, or, if your browser doesn't support File API, you can manually paste file contents into Drill 2.

Files you select and data you paste never leave your computer. Nothing is uploaded to remote servers. Drill 2 works completely within your browser.

## File format

Drill files consist of question blocks separated with double newlines. Each question block consists of question body and answers.

Answers are placed in separate lines and start with subsequent alphabet letters followed by a closing parenthesis. Correct answers are prefixed with three *greater than* characters.

Here's an example of a question file with two questions:

    This is the first question. Which animal is the largest?
    A) Ant - this answer is incorrect
    >>>B) Male cat - correct answer
    >>>C) Female cat - another correct answer
    D) Spider - incorrect one

    Second question. What are you?
    >>>A) A man
    B) A mouse

Files should be saved with UTF-8 encoding.

## Options block

Drill 2 introduces `<options>` blocks that can be embedded in question bank files without breaking backward compatibility. `<options>` blocks can be used to preconfigure default options for question bank. (For example set proper grading schema.)

`<options>` block must be located after last question and separated with at least one newline.

    <options> {
        "format": "2",
		"markdown": true,
        "grading": "perAnswer",
        "radical": true,
        "ptsPerQuestion": 1,
        "timeLimit": 0
    }

If a property is ommited, default value will be used. Property names are always double-quoted. This is not always the case for property values.

- `format` - Used for specifying file format version. Will be used in the future to detect possibly unsupported features in not-up-to-date instances.
    - `"legacy"` - means that file was created with PDS in mind (default value)
    - `"2"` - first version of Drill 2 to support `<options>` blocks

- `markdown` - Can be used to enable Markdown parsing for question bodies. Users can opt out of using Markdown, but they can't opt in if this property is set to false.
    - `false` - disable Markdown (default value)
    - `true` - enable Markdown with opt-out possibility

- `grading` - Selects grading rules.
    - `"perAnswer"` - each correct answer is worth 1 point. Total amount of points that can be scored on a question depends on number of correct answers. (default value)
    - `"perQuestion"` - each question is worth fixed, configurable amount of points (see *ptsPerQUestion*). Answer's worth of point depends on number of correct answers.
    - `"custom: <oneliner>"` - provided JavaScript oneliner will be used to grade questions. Oneliner should be based on chained ternary operators and can access four variables: `correct` - no. of checked correct answers, `incorrect` - no. of checked incorrect answers, `missed` - no. of not checked correct answers, `total` - total no. of correct answers.

- `radical` - Chooses incorrect answer handling
    - `true` - any incorrect answer causes question to be graded to 0 points. (default value)
    - `false` - incorrect answers counterbalance correct answers.

- `ptsPerQuestion` - How many points one question is worth. Applies only if `"grading"` is set to `"perQuestion"`. Accepts numeric values.

- `timeLimit` - How many seconds does student have to answer each question. When that time passes, all answers are unchecked and the question is graded instantly.
    - `0` - time per question isn't limited. (default value)
    - *any other number* - student has that amount of seconds to answer each question.

- `repeatIncorrect` - whether questions with incorrect answers should be returned back into the question queue and asked again.
    - `false` - Just ask every question once. (default value)
    - `true` - Repeat questions until they are answered correctly.

- `explain` - whether explainations should be shown automatically if they are available.
    - `"summary"` - explainations are shown only on the summary screen.
    - `"optional"` - wait until user clicks the button. (default value)
    - `"always"` - show explainations immediately when checking answers.

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
