angular.module('DrillApp').service 'QuestionMerger', (QuestionBuilder) ->
  new class
    merge: (q1, q2) ->
      builder = new QuestionBuilder()
      .setIdentifier(q1.id)

      builder.appendToBody(q1.body) if (q1.body.trim().length) > 0
      builder.appendToBody(q2.body) if (q2.body.trim().length) > 0

      builder
      .addAnswers(q1.answers)
      .addAnswers(q2.answers)
      .build()
