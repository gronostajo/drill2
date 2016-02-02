gulp = require 'gulp'

$ = (require 'gulp-load-plugins')()
beep = require 'beepbeep'
bowerFiles = require 'main-bower-files'
del = require 'del'
runSequence = require 'run-sequence'
sort = require 'sort-stream'

pkg = require './package.json'

deployPath = 'build'
$.util.log "Project: #{pkg.name} v#{pkg.version}"



sortFiles = (a, b) ->
  countUnderscores = (s) ->
    for i in [0..s.length-1]
      return i if s[i] isnt '_'
    return s.length
  [_, ..., filename_a] = a.path.replace(/\\/g, '/').split('/')
  [_, ..., filename_b] = b.path.replace(/\\/g, '/').split('/')
  count_a = countUnderscores(filename_a)
  count_b = countUnderscores(filename_b)
  if count_a == count_b
    filename_a.substring(count_a).localeCompare filename_b.substring(count_b)
  else
    if count_a < count_b then 1 else -1



### Scripts ###

coffeeStream = $.coffee(bare: yes)
coffeeStream.on 'error', (error) ->
  $.util.log(error)
  beep()
  coffeeStream.end()

gulp.task 'coffee', ->
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
  gulp.src(['src/*.html', 'src/view/**/*.html'], base: 'src')
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
  bowerFilesToInject = bowerFiles()                         # MathJax requires crazy inclusion args,
  bowerFilesToInject.push '!bower_components/MathJax/**/*'  # we're doing that manually.

  gulp.src("#{deployPath}/*.html")
  .pipe $.inject gulp.src(bowerFilesToInject, read: false),
    name: 'bower'
    addRootSlash: no
    ignorePath: '/bower_components/'
    addPrefix: 'lib'
  .pipe $.inject gulp.src([
    "#{deployPath}/**/*.js",
    "!#{deployPath}/lib/**/*"]
  , read: no).pipe(sort(sortFiles)),
    relative: yes
  .pipe(gulp.dest deployPath)

gulp.task 'dependencies', (done) ->
  runSequence 'bower', 'inject', done

gulp.task 'bower-init', ->
  $.bower()



### Misc ###

gulp.task 'clean', (done) ->
  del [deployPath], done

gulp.task 'appcache', ->
  date = new Date()
  gulp.src('src/*.appcache', base: 'src')
  .pipe($.replace(/^CACHE MANIFEST/, "CACHE MANIFEST\n
                                     # #{pkg.name} v#{pkg.version}\n
                                     # built on #{date.toDateString()} #{date.toTimeString()}"))
  .pipe(gulp.dest deployPath)

gulp.task 'dev', ->
  gulp.src(['dev/**/*', 'dev/**/.*'], base: 'dev')
  .pipe(gulp.dest deployPath)



### Linter ###

gulp.task 'lint-coffee', ->
  gulp.src('src/**/*.coffee')
  .pipe($.coffeelint 'coffeelint.json')
  .pipe($.coffeelint.reporter())
  .pipe($.coffeelint.reporter 'fail')

gulp.task 'lint-gulpfile', ->
  gulp.src('gulpfile.coffee')
  .pipe($.coffeelint 'coffeelint.json')
  .pipe($.coffeelint.reporter())
  .pipe($.coffeelint.reporter 'fail')

gulp.task 'lint', ['lint-gulpfile', 'lint-coffee'], ->



### Large tasks ###

gulp.task 'build', (done) ->
  runSequence 'lint', 'clean', 'view', 'scripts', 'dependencies', 'appcache', done

gulp.task 'build-dev', ['lint'], (done) ->
  runSequence 'build', 'dev', done

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
