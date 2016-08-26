WEBAPP_DIR = 'build';
TEST_DIR = 'test/build';

module.exports = function (config) {
    config.set({
        basePath: '../',

        files: [
            // bower:js
            // endbower
            'build/app/**/*.js',
            'test/build/**/*.js'
        ],

        browserNoActivityTimeout: 3000,

        client: {
            captureConsole: true
        },

        frameworks: [
            'jasmine',
            'jasmine-matchers'
        ],

        browsers: ['PhantomJS'],

        reporters: ['mocha'],

        plugins: [
            'karma-phantomjs-launcher',
            'karma-jasmine',
            'karma-mocha-reporter',
            'karma-jasmine-matchers'
        ]
    })
};
