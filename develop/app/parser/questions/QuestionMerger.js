angular.module('DrillApp').service('QuestionMerger', function(QuestionBuilder) {
  return new ((function() {
    function _Class() {}

    _Class.prototype.merge = function(q1, q2) {
      var builder;
      builder = new QuestionBuilder().setIdentifier(q1.id);
      if ((q1.body.trim().length) > 0) {
        builder.appendToBody(q1.body);
      }
      if ((q2.body.trim().length) > 0) {
        builder.appendToBody(q2.body);
      }
      return builder.addAnswers(q1.answers).addAnswers(q2.answers).build();
    };

    return _Class;

  })());
});
