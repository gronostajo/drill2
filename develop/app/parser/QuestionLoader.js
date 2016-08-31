angular.module('DrillApp').service('QuestionLoader', function ($q, SafeEvalService, LegacyParser) {
    //
    // TODO extract this to a worker
    //
    var ret = {
        loadFromString: function (input) {
            var bankInfo = {};
            var config = {};

            var qs = input.split(/(?:\r?\n){2,}/);

            var options = {
                format: 'legacy',
                markdown: false,
                mathjax: false,
                grading: 'perAnswer',
                radical: true,
                ptsPerQuestion: 1,
                timeLimit: 0,
                repeatIncorrect: false,
                explain: 'optional'
            };
            var expl = false;

            var matched = /<options>\s*(\{(?:.|\n|\r)*})\s*/i.exec(qs[qs.length - 1]);
            if (matched) {
                qs.pop();

                try {
                    var loaded = JSON.parse(matched[1]);
                } catch (e) {
                    console.error('Invalid <options> object:', matched[1]);
                }

                for (var key in loaded) {
                    if (key == 'explanations') {
                        expl = loaded[key];
                    }
                    else if (options.hasOwnProperty(key)) {
                        options[key] = loaded[key];
                    }
                }
            }

            switch (options.format) {
                case 'legacy':
                case '2':
                case '2.1':
                    bankInfo.fileFormat = options.format;
                    break;

                default:
                    bankInfo.fileFormat = 'unknown';
                    break;
            }

            config.markdownReady = !!options.markdown;
            config.markdown = config.markdownReady;

            config.mathjaxReady = !!options.mathjax;
            config.mathjax = config.mathjaxReady;

            config.customGrader = false;

            if ((options.grading == 'perQuestion') || (options.grading == 'perAnswer')) {
                // for built-in graders, just accept them
                config.gradingMethod = options.grading;
            }
            else {
                //noinspection JSDuplicatedDeclaration
                matched = /^custom: *(.+)$/.exec(options.grading);
                if (matched) {
                    try {
                        SafeEvalService.eval(matched[1], function (id) {
                            return (id == 'total') ? 3 : 1;
                        });
                        config.gradingMethod = 'custom';
                        config.customGrader = matched[1];
                    }
                    catch (ex) {
                        console.error('Custom grader caused an error when testing.');
                    }
                }
                else {
                    config.gradingMethod = 'perAnswer';
                }
            }

            config.gradingRadical = options.radical ? '1' : '0';
            config.gradingPPQ = parseInt(options.ptsPerQuestion);

            var secs = (parseInt(options.timeLimit) / 5) * 5;
            if (!secs) {
                config.timeLimitEnabled = false;
                config.timeLimitSecs = 60;
            }
            else {
                config.timeLimitEnabled = true;
                config.timeLimitSecs = secs;
            }

            config.repeatIncorrect = !!options.repeatIncorrect;

            if (expl && /summary|optional|always/i.exec(options.explain)) {
                config.explain = options.explain.toLowerCase();
            }
            else if (expl) {
                config.explain = 'optional';
            }
            config.showExplanations = (config.explain == 'always');

            var questionsString = qs.join('\n\n');
            var parsingResult = LegacyParser.parse(questionsString);
            var loadedQuestions = parsingResult.questions;
            for (var i = 0; i < parsingResult.log.length; i++) {
                console.warn(parsingResult.log[i]);
            }

            bankInfo.explanationsAvailable = false;
            if (expl) {
                for (var q = 0; q < loadedQuestions.length; q++) {
                    loadedQuestions[q].loadExplanation(expl);
                    if (loadedQuestions[q].hasExplanations) {
                        bankInfo.explanationsAvailable = true;
                    }
                }
            }

            bankInfo.questionCount = loadedQuestions.length;

            return $q.resolve({
                bankInfo: bankInfo,
                config: config,
                loadedQuestions: loadedQuestions,
                log: parsingResult.log
            });
        }
    };

    // Ugly as hell, but it will do for now. I'm too lazy to wrap it properly.
    var originalLoadFromString = ret.loadFromString;
    ret.loadFromString = function (input) {
        try {
            return originalLoadFromString(input);
        } catch (e) {
            return $q.reject(e);
        }
    };

    return ret;
});
