angular.module('DrillApp').service('QuestionLoader', function ($q, SafeEvalService, LegacyParser, OptionsBlockProcessor) {
    //
    // TODO extract this to a worker
    //
    var ret = {
        loadFromString: function (input) {
            var qs = input.split(/(?:\r?\n){2,}/);

            var bankInfo = {};
            var config = {};
            var log = [];

            var matched = /<options>\s*(\{(?:.|\n|\r)*})\s*/i.exec(qs[qs.length - 1]);
            if (matched) {
                qs.pop();
                var optionsBlockContents = matched[1];
                config = OptionsBlockProcessor.process(optionsBlockContents, function (msg) {
                    log.push(msg);
                });
            }

            bankInfo.fileFormat = config.fileFormat || 'legacy';
            var expl = config.explanations;
            delete config.explanations;

            var questionsString = qs.join('\n\n');
            var parsingResult = LegacyParser.parse(questionsString);
            var loadedQuestions = parsingResult.questions;

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
                log: log.concat(parsingResult.log)
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
