// generated on 2016-05-05 using generator-gulp-webapp 1.1.1
import gulp                from 'gulp';
import gulpLoadPlugins     from 'gulp-load-plugins';
// import ghaml               from 'gulp-ruby-haml';
// import rename              from 'gulp-rename';
import jadeInheritance     from'gulp-jade-inheritance';
import browserSync         from 'browser-sync';
import del                 from 'del';
import {stream as wiredep} from 'wiredep';

const $ = gulpLoadPlugins();
const reload = browserSync.reload;

const path = {
  "js":     { "app": "app/public/javascripts", "tmp": ".tmp/public/javascripts", "dist": "dist/public/javascripts" },
  "css":    { "app": "app/public/stylesheets", "tmp": ".tmp/public/stylesheets", "dist": "dist/public/stylesheets" },
  "img":    { "app": "app/public/images",      "tmp": ".tmp/public/images",      "dist": "dist/public/images"      },
  "font":   { "app": "app/public/fonts",       "tmp": ".tmp/public/fonts",       "dist": "dist/public/fonts"       },
  "html":   { "app": "app/mockup",             "tmp": ".tmp/mockup",             "dist": "dist/mockup"             },
  "apis":   { "app": "app/public/apis",        "tmp": ".tmp/public/apis",        "dist": "dist/public/apis"        },
  "layout": { "app": "app/_layouts" }
};

var locals = {};

gulp.task('styles', () => {
  gulp.src(path.css.app + '/vendor/**/*.*').pipe(gulp.dest(path.css.tmp + '/vendor/')).pipe(gulp.dest(path.css.dist + '/vendor/'));
  return gulp.src(path.css.app + '/*.scss')
    .pipe($.plumber())
    .pipe($.sass.sync({
      outputStyle  : 'compact',
      sourcemap    : 'none',
      precision    : 10,
      includePaths : ['./bower_components/compass-mixins/lib/', './bower_components/susy/sass/', 'bower_components/compass-breakpoint/stylesheets/']
    }).on('error', $.sass.logError))
    .pipe($.autoprefixer({browsers: ['> 5%', 'last 3 versions', 'Firefox ESR']}))
    // .pipe($.autoprefixer('last 2 version', 'safari 6', 'ie 9', 'opera 12.1', 'ios 7', 'android 4'))
    .pipe(gulp.dest(path.css.tmp))
    .pipe(gulp.dest(path.css.dist))
    .pipe(reload({stream: true}));
});

gulp.task('scripts', () => {
  gulp.src(path.js.app + '/vendor/**/*.*').pipe(gulp.dest(path.js.tmp + '/vendor/')).pipe(gulp.dest(path.js.dist + '/vendor/'));
  return gulp.src(path.js.app+'/**/*.coffee')
    .pipe($.plumber())
    // .pipe($.babel())
    .pipe($.coffee())
    .pipe(gulp.dest(path.js.tmp))
    .pipe(gulp.dest(path.js.dist))
    .pipe(reload({stream: true}));
});

function lint(files, options) {
  return () => {
    return gulp.src(files)
      .pipe(reload({stream: true, once: true}))
      .pipe($.eslint(options))
      .pipe($.eslint.format())
      .pipe($.if(!browserSync.active, $.eslint.failAfterError()));
  };
}
function colint(files, options) {
  return () => {
    return gulp.src(files)
      .pipe(reload({stream: true, once: true}))
      .pipe($.coffeelint(options))
      .pipe($.if(!browserSync.active, $.coffeelint.reporter()))
  };
}
const testLintOptions = { env: { mocha: true } };
const testCoffeeLintOptions = { globals: { "jQuery": false, '$': true, "angular": false } };
const jadeOptions = {locals: (__dirname + '/app/') };

gulp.task('lint', lint(path.js.app+'/**/*.js'));
gulp.task('colint', colint(path.js.tmp+'/**/*.coffee'));

gulp.task('html', () => {
  // console.log(require('./data.json'));
  // console.log(__dirname + '/data.json');
  return gulp.src(path.html.app + '/**/*.jade')
    // .pipe($.data( (file) => { return (__dirname + '/data.json') } ))

    // .pipe(jadeInheritance({basedir: (__dirname + '/app/mockup/') }))
    .pipe($.jade({pretty: true, cache: true})).on('error', function(e) { console.log(e.message); })
    // .pipe($.useref({searchPath: ['.tmp', 'app', '.']}))

    // .pipe($.if('*.js', $.uglify()))
    // .pipe($.if('*.css', $.cssnano()))
    // .pipe($.if('*.html', $.htmlmin({collapseWhitespace: true})))

    .pipe(gulp.dest(path.html.tmp))
    .pipe(gulp.dest(path.html.dist))
    .pipe(reload({stream: true}));
});

gulp.task('images', () => {
  return gulp.src(path.img.app+ '/**/*')
    .pipe($.if($.if.isFile, $.cache($.imagemin({
      progressive: true,
      interlaced: true,
      svgoPlugins: [{cleanupIDs: false}]
    }))
    .on('error', function (err) {
      console.log(err);
      this.end();
    })))
    .pipe(gulp.dest(path.img.dist))
    .pipe(reload({stream: true}));
});

gulp.task('fonts', () => {
  return gulp.src(require('main-bower-files')('**/*.{eot,svg,ttf,woff,woff2}', function (err) {})
    .concat(path.font.app + '/**/*'))
    .pipe(gulp.dest(path.font.tmp))
    .pipe(gulp.dest(path.font.dist))
    .pipe(reload({stream: true}));
});

gulp.task('apis', () => {
  return gulp.src(require('main-bower-files')('**/apis/*.json', function (err) {})
    .concat(path.apis.app + '/**/*'))
    .pipe(gulp.dest(path.apis.tmp))
    .pipe(gulp.dest(path.apis.dist))
    .pipe(reload({stream: true}));
});

gulp.task('extras', () => {
  return gulp.src([ 'app/*.*', '!app/*.jade' ], {  dot: true }).pipe(gulp.dest('dist'));
});

gulp.task('clean', del.bind(null, ['.tmp', 'dist']));

gulp.task('serve', ['html', 'styles', 'scripts', 'fonts', 'apis'], () => {
  browserSync({
    open: false,
    notify: false,
    port: 9000,
    server: { baseDir: ['.tmp', 'app'], routes: { '/bower_components': 'bower_components' } }
  });

  gulp.watch([path.layout.app + '/**/*.jade', path.html.app + '/**/*.jade'],   ['html']             );//.on('change', browserSync.reload);
  gulp.watch(path.css.app     + '/**/*.scss',                                  ['styles']           );//.on('change', browserSync.reload);
  gulp.watch([path.js.app     + '/**/*.js'  , path.js.app   + '/**/*.coffee'], ['scripts']          );//.on('change', browserSync.reload);
  gulp.watch(path.font.app    + '/**/*'     ,                                  ['fonts']            );//.on('change', browserSync.reload);
  gulp.watch('bower.json',                                                     ['wiredep', 'fonts'] );//.on('change', browserSync.reload);
});

gulp.task('serve:dist', () => {
  browserSync({
    open: false,
    notify: false,
    port: 9000,
    server: { baseDir: ['dist'] }
  });
});

gulp.task('serve:test', ['scripts'], () => {
  browserSync({
    open: false,
    notify: false,
    port: 9000,
    ui: false,
    server: { baseDir: 'test', routes: { '/scripts': path.js.tmp, '/bower_components': 'bower_components' } }
  });

  gulp.watch(path.js.app + '/**/*.js', ['scripts']);
  gulp.watch('test/spec/**/*.js').on('change', reload);
  gulp.watch('test/spec/**/*.js', ['lint:test']);
});

// inject bower components
// https://www.chedanji.com/bower-with-wiredep/
gulp.task('wiredep', () => {
  gulp.src(path.css.app + '/*.scss')
    .pipe(wiredep({
      ignorePath: /^(\.\.\/)+/
    }))
    .pipe(gulp.dest(path.css.app + ''));

  gulp.src('app/**/*.jade')
    .pipe(wiredep({
      // exclude: ['bootstrap-sass'],
      ignorePath: /^(\.\.\/)*\.\./
    }))
    .pipe(gulp.dest('app'));
});

gulp.task('build', ['colint', 'styles', 'scripts', 'html', 'images', 'fonts', 'extras'], () => {
  return gulp.src('dist/**/*').pipe($.size({title: 'build', gzip: false}));
});

gulp.task('default', ['clean'], () => {
  gulp.start('build');
});
