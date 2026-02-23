WEBAPP_DIR = 'build';
TEST_DIR = 'test/build';

module.exports = (config) ->
  config.set
    basePath: '../'

    files: [
      # bower:js
      # endBower
      'build/app/**/*.js'
      'test/build/**/*.js'
    ]

    browserNoActivityTimeout: 3000

    client:
      captureConsole: yes

    frameworks: [
      'jasmine'
      'jasmine-matchers'
    ]

    customLaunchers:
      HeadlessChrome:
        base: 'ChromeHeadless'
        flags: ['--no-sandbox']

    browsers: ['HeadlessChrome']

    reporters: ['mocha']

    plugins: [
      'karma-chrome-launcher'
      'karma-jasmine'
      'karma-mocha-reporter'
      'karma-jasmine-matchers'
    ]

    mochaReporter:
      ignoreSkipped: yes
