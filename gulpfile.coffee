gulp = require 'gulp'

$ = (require('gulp-load-plugins'))()
beep = require('beepbeep')
bowerFiles = require('main-bower-files')
del = require('del')
KarmaServer = require('karma').Server
runSequence = require('run-sequence')
streamEnd = require('stream-end')

pkg = require('./package.json')

deployPath = 'build'
$.util.log "Project: #{pkg.name} v#{pkg.version}"


### Scripts ###

gulp.task 'coffee', ->
  coffeeStream = $.coffee(bare: yes)
  coffeeStream.on 'error', (error) ->
    $.util.log(error)
    beep()
    coffeeStream.end()
  gulp.src(['src/app/**/*.coffee', 'src/lib/**/*.coffee'], base: 'src')
  .pipe(coffeeStream)
  .pipe(gulp.dest deployPath)

gulp.task 'js', ->
  gulp.src(['src/app/**/*.js', 'src/lib/**/*.js'], base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'scripts', (done) ->
  runSequence 'js', 'coffee', done


### View ###

gulp.task 'html', ->
  gulp.src(['src/*.html', 'src/app/**/*.html', 'src/view/**/*.html'], base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'css', ->
  gulp.src('src/view/**/*.css', base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'view', (done) ->
  runSequence 'html', 'css', done


### Dependencies ###

gulp.task 'bower', ->
  gulp.src(bowerFiles(), base: 'bower_components')
  .pipe(gulp.dest("#{deployPath}/lib"))

gulp.task 'inject', ['view'], ->
  bowerFilesToInject = bowerFiles().concat [
    '!bower_components/MathJax/**'            # MathJax requires crazy inclusion args, we're doing that manually.
    '!bower_components/bootstrap/**/*.css'    # Included manually for theme switcher
    '!bower_components/bootswatch/**/*.css'   # Included manually for theme switcher
  ]

  gulp.src("#{deployPath}/*.html")
  .pipe $.inject gulp.src(bowerFilesToInject, read: false),
    name: 'bower'
    addRootSlash: no
    ignorePath: '/bower_components/'
    addPrefix: 'lib'
  .pipe $.inject gulp.src([
    "#{deployPath}/**/*.js",
    "!#{deployPath}/lib/**"]
  , read: no),
    relative: yes
  .pipe(gulp.dest deployPath)

gulp.task 'dependencies', (done) ->
  runSequence 'bower', 'inject', done

gulp.task 'bower-init', ->
  $.bower()


### Tests ###

gulp.task 'build-tests', ->
  coffeeStream = $.coffee(bare: yes)
  coffeeStream.on 'error', (error) ->
    $.util.log(error)
    beep()
    coffeeStream.end()
  gulp.src(['test/src/**/*.coffee'], base: 'test/src')
  .pipe(coffeeStream)
  .pipe(gulp.dest 'test/build')

gulp.task 'configure-karma', ->
  bowerFilesToInject = bowerFiles(includeDev: yes).concat [
    '!bower_components/MathJax/**'
  ]
  dependencies = gulp.src(bowerFilesToInject, read: false)
  .pipe($.ignore.include('**/*.js'))

  require('child_process').execSync("git update-index --assume-unchanged \"#{__dirname}/test/karma.conf.coffee\"")

  gulp.src('test/karma.conf.coffee')
  .pipe $.inject dependencies,
    addRootSlash: no
    starttag: '# bower:{{ext}}'
    endtag: '# endBower'
    transform: (filepath) -> "'#{filepath}'"
  .pipe(gulp.dest('test'))

gulp.task 'run-tests', ['build-tests', 'configure-karma'], (done) ->
  new KarmaServer(
    configFile: __dirname + '/test/karma.conf.coffee'
    singleRun: yes
  , done).start()


### Misc ###

gulp.task 'clean', (done) ->
  del([deployPath, 'test/build'], done)

appcacheFiles = [
  '**'
  '!**/.ht*'
  '!**/*.appcache'
  '!lib/MathJax/**'
  '!lib/bootstrap/dist/fonts/!(glyphicons-halflings-regular.woff)'  # save some bytes by including only one font
  '!lib/bootswatch/fonts/!(glyphicons-halflings-regular.woff)'
]

gulp.task 'appcache', ->
  date = new Date()

  cachedFiles = gulp.src(appcacheFiles, read: no, cwd: deployPath, nodir: yes)
  .pipe($.sort())

  gulp.src('src/*.appcache', base: 'src')
  .pipe($.replace(/^CACHE MANIFEST/, "CACHE MANIFEST\n
                                     # #{pkg.name} v#{pkg.version}\n
                                     # built on #{date.toDateString()} #{date.toTimeString()}"))
  .pipe $.inject cachedFiles,
    addRootSlash: no
    starttag: '# inject'
    endtag: '# endInject'
    transform: (path) -> path
  .pipe(gulp.dest deployPath)

gulp.task 'dev', (done) ->
  gulp.src(['dev/**', 'dev/**/.*'], base: 'dev')
  .pipe(gulp.dest deployPath)
  del("#{deployPath}/*.appcache", done)


### Reports ###

gulp.task 'sloc-src', ->
  gulp.src(['src/**'], nodir: yes)
  .pipe($.sloc2
    reportType: 'json'
    reportFile: 'sloc-src.json'
  )
  .pipe(gulp.dest('reports'))

gulp.task 'sloc-test', ->
  gulp.src(['test/src/**'], nodir: yes)
  .pipe($.sloc2
    reportType: 'json'
    reportFile: 'sloc-test.json'
  )
  .pipe(gulp.dest('reports'))

gulp.task 'size', ->
  size = $.size(showTotal: no)
  gulp.src(appcacheFiles.concat('*.appcache'), cwd: deployPath, nodir: yes)
  .pipe(size)
  .pipe(streamEnd ->
    out = JSON.stringify
      size: size.size
      prettySize: size.prettySize
    $.file('size.json', out, src: yes)
    .pipe(gulp.dest('reports'))
  )

gulp.task 'printReport', ->
  slocSrc = require('./reports/sloc-src.json')
  slocTest = require('./reports/sloc-test.json')
  size = require('./reports/size.json')
  output = [
    "    Source SLOC: #{$.util.colors.green(slocSrc.source)}"
    "     Tests SLOC: #{$.util.colors.green(slocTest.source)}"
    "  Appcache size: #{$.util.colors.green(size.prettySize)}"
  ]
  for line in output
    $.util.log(line)

gulp.task 'report', (done) ->
  runSequence 'sloc-src', 'sloc-test', 'size', 'printReport', done


### Linter ###

gulp.task 'lint-coffee', ->
  gulp.src('src/**/*.coffee')
  .pipe($.coffeelint 'coffeelint.json')
  .pipe($.coffeelint.reporter())
  .pipe($.coffeelint.reporter 'fail')

gulp.task 'lint-tests', ->
  gulp.src('test/src/**/*.coffee')
  .pipe($.coffeelint 'coffeelint.json')
  .pipe($.coffeelint.reporter())
  .pipe($.coffeelint.reporter 'fail')

gulp.task 'lint-gulpfile', ->
  gulp.src('gulpfile.coffee')
  .pipe($.coffeelint 'coffeelint.json')
  .pipe($.coffeelint.reporter())
  .pipe($.coffeelint.reporter 'fail')

gulp.task 'lint', (done) ->
  runSequence 'lint-gulpfile', 'lint-coffee', 'lint-tests', done


### Large tasks ###

gulp.task 'build', (done) ->
  runSequence 'lint', 'clean', 'view', 'scripts', 'dependencies', 'appcache', 'report', done

gulp.task 'build-dev', ['lint'], (done) ->
  runSequence 'build', 'dev', 'report', done

gulp.task 'test', (done) ->
  runSequence 'build-dev', 'run-tests', done

gulp.task 'init', (done) ->
  runSequence 'bower-init', 'help', done

gulp.task 'help', ->
  $.util.log '\n
           \n  `gulp build`     - production build
           \n  `gulp build-dev` - development build
           \n'


gulp.task 'default', ->
  $.util.log '\n
              \nRun `npm install` if you haven\'t yet.
              \nThen `gulp init` and wait for instructions.
              \n'
