gulp = require 'gulp'

$ = (require('gulp-load-plugins'))()
appcacheFiles = require('appcache-files')
argv = require('yargs').argv
beep = require('beepbeep')
bowerFiles = require('main-bower-files')
childProcess = require('child_process')
del = require('del')
fs = require('fs')
groupArray = require('group-array')
KarmaServer = require('karma').Server
merge = require('merge2')
path = require('path')
runSequence = require('run-sequence')

pkg = require('./package.json')

deployPath = 'build'
devBuild = not argv.production

projectVersion = 'v' + pkg.version
if devBuild and fs.existsSync('.git')
  sha = childProcess.execSync('git rev-parse --short HEAD').toString().trim()
  projectVersion += '-' + sha

$.util.log 'Project: ' + $.util.colors.blue("#{pkg.name} #{projectVersion}")


appcacheExclusions = [
  '!**/.ht*'
  '!**/*.appcache'
  '!lib/MathJax/**'
  '!lib/bootstrap/dist/fonts/!(glyphicons-halflings-regular.woff)'  # save some bytes by including only one font
  '!lib/bootswatch/fonts/!(glyphicons-halflings-regular.woff)'
]


### Clean ###

gulp.task 'clean', (done) ->
  del(deployPath, done)

gulp.task 'clean-tests', (done) ->
  del('test/build', done)


### Scripts ###

gulp.task 'coffee', ->
  coffeeStream = $.coffee(bare: yes)
  coffeeStream.on 'error', (error) ->
    $.util.log(error)
    beep()
    coffeeStream.end()
  gulp.src('src/app/**/*.coffee', base: 'src')
  .pipe(coffeeStream)
  .pipe(gulp.dest deployPath)

gulp.task 'js', ->
  gulp.src('src/app/**/*.js', base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'scripts', (done) ->
  runSequence('coffee', 'js', done)


### View ###

gulp.task 'html', ->
  gulp.src(['src/*.html', 'src/app/**/*.html', 'src/view/**/*.html'], base: 'src')
  .pipe($.replace('<!-- drill2ver -->', projectVersion))
  .pipe(gulp.dest deployPath)

gulp.task 'css', ->
  gulp.src('src/view/**/*.css', base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'view', (done) ->
  runSequence('html', 'css', done)


### Dependencies ###

gulp.task 'bower', ->
  gulp.src(bowerFiles(), base: 'bower_components')
  .pipe(gulp.dest("#{deployPath}/lib"))

gulp.task 'inject', ->
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
  runSequence('bower', 'inject', done)


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

gulp.task 'run-tests', (done) ->
  new KarmaServer(
    configFile: __dirname + '/test/karma.conf.coffee'
    singleRun: yes
  , done).start()


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


### Misc ###

gulp.task 'appcache', ->
  return if devBuild

  date = new Date()

  cachedFiles = gulp.src(appcacheExclusions.concat('**'), read: no, cwd: deployPath, nodir: yes)
  .pipe($.sort())

  gulp.src('src/*.appcache', base: 'src')
  .pipe($.replace(/^CACHE MANIFEST/, """
                                     CACHE MANIFEST
                                     # #{pkg.name} v#{pkg.version}
                                     # built on #{date.toDateString()} #{date.toTimeString()}
                                     """))
  .pipe $.inject cachedFiles,
    addRootSlash: no
    starttag: '# inject'
    endtag: '# endInject'
    transform: (path) -> path
  .pipe(gulp.dest deployPath)

gulp.task 'env-specific', (done) ->
  env = if devBuild then 'dev' else 'prod'
  gulp.src(["#{env}/**", "#{env}/**/.*"], base: env)
  .pipe(gulp.dest deployPath)
  if devBuild
    del("#{deployPath}/*.appcache", done)
  else done()


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

size = null

gulp.task 'calculate-size', ->
  size = $.size(showTotal: no)
  gulp.src(appcacheExclusions.concat('**'), cwd: deployPath, nodir: yes)
  .pipe(size)

gulp.task 'size', ['calculate-size'], ->
  out = JSON.stringify
    size: size.size
    prettySize: size.prettySize
  $.file('size.json', out, src: yes)
  .pipe(gulp.dest('reports'))

loadJson = (relativePath) ->
  JSON.parse(fs.readFileSync(relativePath, 'utf-8'))

gulp.task 'report', ['sloc-src', 'sloc-test', 'size'], ->
  buildType = if devBuild then $.util.colors.green('development') else $.util.colors.blue('production')
  slocSrc = loadJson('reports/sloc-src.json')
  slocTest = loadJson('reports/sloc-test.json')
  size = loadJson('reports/size.json')
  output = [
    "      Built for: #{buildType}"
    "    Source SLOC: #{$.util.colors.yellow(slocSrc.source)}"
    "     Tests SLOC: #{$.util.colors.yellow(slocTest.source)}"
    "  Appcache size: #{$.util.colors.yellow(size.prettySize)}"
  ]
  for line in output
    $.util.log(line)

firstPathPart = (path) ->
  slashIndex = path.replace('\\', '/').indexOf('/')
  if slashIndex is -1 then '.' else path.substr(0, slashIndex)

gulp.task 'appcache-details', ->
  files = appcacheFiles("#{deployPath}/drill2.appcache")
  groupedFiles = groupArray files, (path) ->
    firstDir = firstPathPart(path)
    if firstDir isnt 'lib'
      firstDir
    else
      firstDir + '/' + firstPathPart(path.substr(firstDir.length + 1))
  streams = for group, paths of groupedFiles
    gulp.src(paths, cwd: deployPath)
    .pipe($.size(title: group))
  streams.push gulp.src(files, cwd: deployPath).pipe($.size())
  merge.apply(@, streams)


### Core tasks ###

gulp.task 'assets', (done) ->
  runSequence('clean', ['view', 'scripts', 'dependencies'], done)

gulp.task 'build', (done) ->
  runSequence('lint', 'assets', 'appcache', 'env-specific', 'report', done)

gulp.task 'test', (done) ->
  runSequence('clean-tests', 'build', 'build-tests', 'configure-karma', 'run-tests', done)

gulp.task 'default', ['build']
