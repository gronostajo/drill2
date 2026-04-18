gulp = require 'gulp'

$ = (require('gulp-load-plugins'))()
appcacheFiles = require('appcache-files')
argv = require('yargs').argv
beep = require('beepbeep')
childProcess = require('child_process')
colors = require('ansi-colors')
del = require('del')
fs = require('fs')
groupArray = require('group-array')
karma = require('karma')
KarmaServer = karma.Server
parseKarmaConfig = karma.config.parseConfig
log = require('fancy-log')
merge = require('merge2')
path = require('path')
sloc = require('sloc')
through2 = require('through2')

pkg = require('./package.json')

deployPath = 'build'
devBuild = not argv.production

projectVersion = 'v' + pkg.version
if devBuild and fs.existsSync('.git')
  sha = childProcess.execSync('git rev-parse --short HEAD').toString().trim()
  projectVersion += '-' + sha

log 'Project: ' + colors.blue("#{pkg.name} #{projectVersion}")


appcacheExclusions = [
  '!**/.ht*'
  '!**/*.appcache'
  '!lib/MathJax/**'
  '!lib/bootstrap/dist/fonts/!(glyphicons-halflings-regular.woff)'  # save some bytes by including only one font
  '!lib/bootswatch/fonts/!(glyphicons-halflings-regular.woff)'
]


### Clean ###

gulp.task 'clean', ->
  del("#{deployPath}/*")

gulp.task 'clean-tests', ->
  del('test/build')


### Scripts ###

gulp.task 'coffee', ->
  coffeeStream = $.coffee(bare: yes)
  coffeeStream.on 'error', (error) ->
    log(error)
    beep()
    coffeeStream.end()
  gulp.src('src/app/**/*.coffee', base: 'src')
  .pipe(coffeeStream)
  .pipe(gulp.dest deployPath)

gulp.task 'js', ->
  gulp.src('src/app/**/*.js', base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'scripts', gulp.series('coffee', 'js')


### View ###

gulp.task 'html', ->
  gulp.src(['src/*.html', 'src/app/**/*.html', 'src/view/**/*.html'], base: 'src')
  .pipe($.replace('<!-- drill2ver -->', projectVersion))
  .pipe(gulp.dest deployPath)

gulp.task 'css', ->
  gulp.src('src/view/**/*.css', base: 'src')
  .pipe(gulp.dest deployPath)

gulp.task 'view', gulp.series('html', 'css')


### Dependencies ###

# Files copied to build/lib/ (preserving sub-paths relative to node_modules/)
npmLibFiles = [
  'node_modules/angular/angular.min.js'
  'node_modules/angular-cookies/angular-cookies.min.js'
  'node_modules/angular-ui-bootstrap/dist/ui-bootstrap-tpls.js'
  'node_modules/bootstrap/dist/css/bootstrap.min.css'
  'node_modules/bootstrap/dist/js/bootstrap.min.js'
  'node_modules/bootstrap/dist/fonts/*'
  'node_modules/bootswatch/cyborg/bootstrap.min.css'
  'node_modules/bootswatch/fonts/*'
  'node_modules/commonmark/dist/commonmark.min.js'
  'node_modules/jquery/dist/jquery.min.js'
  'node_modules/ng-elif/src/elif.js'
  'node_modules/ng-file-upload/dist/ng-file-upload.min.js'
]

# MathJax files (copied separately to preserve lib/MathJax/ capitalisation)
mathjaxFiles = [
  'node_modules/mathjax/MathJax.js'
  'node_modules/mathjax/config/Safe.js'
  'node_modules/mathjax/config/TeX-AMS-MML_HTMLorMML.js'
  'node_modules/mathjax/extensions/**'
  'node_modules/mathjax/fonts/HTML-CSS/TeX/woff/**'
  'node_modules/mathjax/jax/input/MathML/**'
  'node_modules/mathjax/jax/input/TeX/**'
  'node_modules/mathjax/jax/output/HTML-CSS/**'
  'node_modules/mathjax/jax/output/NativeMML/**'
  'node_modules/mathjax/jax/output/PreviewHTML/**'
]

# JS files injected into index.html (no CSS, no MathJax)
npmJsToInject = [
  'node_modules/angular/angular.min.js'
  'node_modules/jquery/dist/jquery.min.js'
  'node_modules/angular-ui-bootstrap/dist/ui-bootstrap-tpls.js'
  'node_modules/commonmark/dist/commonmark.min.js'
  'node_modules/ng-file-upload/dist/ng-file-upload.min.js'
  'node_modules/angular-cookies/angular-cookies.min.js'
  'node_modules/ng-elif/src/elif.js'
  'node_modules/bootstrap/dist/js/bootstrap.min.js'
]

# JS files for karma (same as above + angular-mocks)
karmaJsFiles = npmJsToInject.concat [
  'node_modules/angular-mocks/angular-mocks.js'
]

gulp.task 'deps-lib', ->
  gulp.src(npmLibFiles, base: 'node_modules', encoding: false)
  .pipe(gulp.dest("#{deployPath}/lib"))

gulp.task 'deps-mathjax', ->
  gulp.src(mathjaxFiles, base: 'node_modules/mathjax', encoding: false)
  .pipe(gulp.dest("#{deployPath}/lib/MathJax"))

gulp.task 'deps', gulp.parallel('deps-lib', 'deps-mathjax')

gulp.task 'inject', ->
  gulp.src("#{deployPath}/*.html")
  .pipe $.inject gulp.src(npmJsToInject, read: false, allowEmpty: true),
    name: 'lib'
    addRootSlash: no
    ignorePath: '/node_modules/'
    addPrefix: 'lib'
  .pipe $.inject gulp.src([
    "#{deployPath}/**/*.js",
    "!#{deployPath}/lib/**"]
  , read: no),
    relative: yes
  .pipe(gulp.dest deployPath)

gulp.task 'dependencies', gulp.series('deps', 'inject')


### Tests ###

gulp.task 'build-tests', ->
  coffeeStream = $.coffee(bare: yes)
  coffeeStream.on 'error', (error) ->
    log(error)
    beep()
    coffeeStream.end()
  gulp.src(['test/src/**/*.coffee'], base: 'test/src')
  .pipe(coffeeStream)
  .pipe(gulp.dest 'test/build')

gulp.task 'configure-karma', ->
  dependencies = gulp.src(karmaJsFiles, read: false)

  gulp.src('test/karma.conf.coffee')
  .pipe $.inject dependencies,
    addRootSlash: no
    starttag: '# lib:{{ext}}'
    endtag: '# endLib'
    transform: (filepath) -> "'#{filepath}'"
  .pipe through2.obj (file, enc, cb) ->
    file.path = path.join(path.dirname(file.path), 'karma.conf.generated.coffee')
    cb(null, file)
  .pipe(gulp.dest('test'))

gulp.task 'run-tests', ->
  parseKarmaConfig(
    __dirname + '/test/karma.conf.generated.coffee'
    {singleRun: yes}
    {promiseConfig: yes, throwErrors: yes}
  ).then (karmaConfig) ->
    new Promise (resolve, reject) ->
      server = new KarmaServer karmaConfig, (exitCode) ->
        if exitCode isnt 0
          reject(new Error("Karma exited with code #{exitCode}"))
        else
          resolve()
      server.start()


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

gulp.task 'lint', gulp.series('lint-gulpfile', 'lint-coffee', 'lint-tests')


### Misc ###

gulp.task 'appcache', ->
  return Promise.resolve() if devBuild

  date = new Date()

  cachedFiles = gulp.src(appcacheExclusions.concat('**'), read: no, cwd: deployPath, nodir: yes)
  .pipe through2.obj (file, enc, cb) ->
    fs.stat file.path, (err, stat) ->
      return cb() if err or stat.isDirectory()
      cb(null, file)
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

gulp.task 'env-specific', gulp.series(
  ->
    env = if devBuild then 'dev' else 'prod'
    return Promise.resolve() unless fs.existsSync(env)
    gulp.src(["#{env}/**", "#{env}/**/.*"], base: env)
    .pipe(gulp.dest deployPath)
  ->
    if devBuild then del("#{deployPath}/*.appcache") else Promise.resolve()
)


### Reports ###

slocExtensions = sloc.extensions

makeSloc = (pattern, reportFile) ->
  counters = {total: 0, source: 0, comment: 0, single: 0, block: 0, mixed: 0, empty: 0, file: 0}
  transform = (file, enc, cb) ->
    ext = path.extname(file.path).replace(/^\./, '')
    if ext and slocExtensions.indexOf(ext) >= 0
      stats = sloc(file.contents.toString('utf8'), ext)
      Object.keys(stats).forEach (k) -> counters[k] += stats[k]
      counters.file += 1
    cb()
  flush = (cb) ->
    fs.mkdirSync 'reports', recursive: yes
    fs.writeFileSync reportFile, JSON.stringify(counters)
    cb()
  gulp.src(pattern, nodir: yes)
  .pipe through2.obj(transform, flush)

gulp.task 'sloc-src', ->
  makeSloc ['src/**'], 'reports/sloc-src.json'

gulp.task 'sloc-test', ->
  makeSloc ['test/src/**'], 'reports/sloc-test.json'

size = null

gulp.task 'calculate-size', ->
  size = $.size(showTotal: no)
  gulp.src(appcacheExclusions.concat('**'), cwd: deployPath, nodir: yes)
  .pipe(size)

gulp.task 'size', gulp.series('calculate-size', (done) ->
  out = JSON.stringify
    size: size.size
    prettySize: size.prettySize
  fs.mkdirSync 'reports', recursive: yes
  fs.writeFileSync 'reports/size.json', out
  done()
)

loadJson = (relativePath) ->
  JSON.parse(fs.readFileSync(relativePath, 'utf-8'))

gulp.task 'report', gulp.series(gulp.parallel('sloc-src', 'sloc-test', 'size'), (done) ->
  buildType = if devBuild then colors.green('development') else colors.blue('production')
  slocSrc = loadJson('reports/sloc-src.json')
  slocTest = loadJson('reports/sloc-test.json')
  size = loadJson('reports/size.json')
  output = [
    "      Built for: #{buildType}"
    "    Source SLOC: #{colors.yellow(slocSrc.source)}"
    "     Tests SLOC: #{colors.yellow(slocTest.source)}"
    "  Appcache size: #{colors.yellow(size.prettySize)}"
  ]
  for line in output
    log(line)
  done()
)

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

gulp.task 'assets', gulp.series(
  'clean'
  gulp.parallel('view', 'scripts', 'dependencies')
)

gulp.task 'build', gulp.series('lint', 'assets', 'appcache', 'env-specific', 'report')

gulp.task 'test', gulp.series('clean-tests', 'build', 'build-tests', 'configure-karma', 'run-tests')

gulp.task 'default', gulp.series('build')
