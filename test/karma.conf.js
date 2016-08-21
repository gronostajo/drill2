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

        frameworks: ['jasmine'],

        browsers: ['PhantomJS'],

        reporters: ['progress'],

        plugins: [
            'karma-phantomjs-launcher',
            'karma-jasmine'
        ]
    })
};
