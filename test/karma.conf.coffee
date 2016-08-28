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

    browsers: ['PhantomJS']

    reporters: ['mocha']

    plugins: [
      'karma-phantomjs-launcher'
      'karma-jasmine'
      'karma-mocha-reporter'
      'karma-jasmine-matchers'
    ]
