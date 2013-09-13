'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
    return connect.static(require('path').resolve(dir));
};

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);
  grunt.loadNpmTasks('grunt-generator');
  grunt.loadNpmTasks('grunt-haml');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // configurable paths
  var yeomanConfig = {
    app: 'site',
    dist: 'dist',
    serve: '.tmp'
  };

  grunt.initConfig({
    yeoman: yeomanConfig,

    watch: {
      coffee: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee'],
        tasks: ['coffee:dist']
      },
      coffeeTest: {
        files: ['test/spec/{,*/}*.coffee'],
        tasks: ['coffee:test']
      },
      compass: {
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
        tasks: ['compass']
      },
      livereload: {
        files: [
          '<%= yeoman.app %>/*.html',
          '{<%= yeoman.serve %>,<%= yeoman.app %>}/styles/{,*/}*.html',
          '{<%= yeoman.serve %>,<%= yeoman.app %>}/styles/{,*/}*.css',
          '{<%= yeoman.serve %>,<%= yeoman.app %>}/scripts/{,*/}*.js',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}'
        ],
        tasks: ['livereload']
      }
    },
    connect: {
      options: {
        port: 9000,
        hostname: 'localhost' // change this to '0.0.0.0' to access the server from outside
      },
      livereload: {
        options: {
          middleware: function (connect) {
            return [
              lrSnippet,
              mountFolder(connect, '<%= yeoman.serve %>'),
              mountFolder(connect, 'app')
            ];
          }
        }
      },
      test: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, '<%= yeoman.serve %>'),
              mountFolder(connect, 'test')
            ];
          }
        }
      },
      dist: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, 'dist')
            ];
          }
        }
      }
    },
    open: {
      server: {
        path: 'http://localhost:<%= connect.options.port %>'
      }
    },
    clean: {
      dist: ['<%= yeoman.serve %>', '<%= yeoman.dist %>/*'],
      server: '<%= yeoman.serve %>'
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      all: [
        'Gruntfile.js',
        '<%= yeoman.app %>/scripts/{,*/}*.js',
        '!<%= yeoman.app %>/scripts/vendor/*',
        '!<%= yeoman.app %>/scripts/libs/*',
        '!<%= yeoman.app %>/scripts/plugins/*',
        'test/spec/{,*/}*.js'
      ]
    },
    coffee: {
      dist: {
        files: [{
          // rather than compiling multiple files here you should
          // require them into your main .coffee file
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '*.coffee',
          dest: '<%= yeoman.dist %>/scripts',
          ext: '.js'
        }]
      },
      serve: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '*.coffee',
          dest: '<%= yeoman.serve %>/scripts',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.serve %>/spec',
          src: '*.coffee',
          dest: 'test/spec'
        }]
      }

    },
    compass: {
      options: {
        cssDir: '<%= yeoman.serve %>/styles',
        sassDir: '<%= yeoman.app %>/styles',
        imagesDir: '<%= yeoman.app %>/images',
        javascriptsDir: '<%= yeoman.serve %>/scripts',
        relativeAssets: true,
        force: true
      },
      dist: {},
      server: {
        options: {
          debugInfo: true
        }
      }
    },
    // not used since Uglify task does concat,
    // but still available if needed
    /*concat: {
     dist: {}
     },*/
    requirejs: {
      dist: {
        // Options: https://github.com/jrburke/r.js/blob/master/build/example.build.js
        options: {
          // `name` and `out` is set by grunt-usemin
          baseUrl: 'app/scripts',
          optimize: 'none',
          // TODO: Figure out how to make sourcemaps work with grunt-usemin
          // https://github.com/yeoman/grunt-usemin/issues/30
          //generateSourceMaps: true,
          // required to support SourceMaps
          // http://requirejs.org/docs/errors.html#sourcemapcomments
          preserveLicenseComments: false,
          useStrict: true,
          wrap: true,
          //uglify2: {} // https://github.com/mishoo/UglifyJS2
        }
      }
    },
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      options: {
        dirs: ['<%= yeoman.dist %>']
      }
    },
    cssmin: {
      dist: {
        files: {
          '<%= yeoman.dist %>/styles/index.css': [
            '<%= yeoman.serve %>/styles/{,*/}*.css',
            '<%= yeoman.app %>/styles/{,*/}*.css'
          ]
        }
      }
    },
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: [
            '*.{ico,txt}',
            '.htaccess',
            'images/{,*/}*.{webp,gif}'
          ]
        }]
      }
    },
    bower: {
      install: {
      },
      all: {
        rjsConfig: '<%= yeoman.app %>/scripts/main.js'
      }
    },

    jekyll: {                             // Task
      options: {                          // Universal options
        bundleExec: true,
        src : 'site'
      },
      dist: {                             // Target
        options: {                        // Target options
          dest: '<%= yeoman.dist %>',
          config: 'site/_config.yml'
        }
      },
      serve: {                            // Another target
        options: {
          dest: '<%= yeoman.serve %>',
          drafts: true
        }
      }
    }

  });

    grunt.renameTask('regarde', 'watch');

    grunt.registerTask('server', function (target) {
        if (target === 'dist') {
            return grunt.task.run(['build', 'open', 'connect:dist:keepalive']);
        }

        grunt.task.run([
            'clean:server',
            'coffee:dist',
            'jekyll:serve',
            'compass:server',
            'livereload-start',
            'connect:livereload',
            'open',
            'watch'
        ]);
    });

    grunt.registerTask('test', [
        'clean:server',
        'coffee',
        'compass',
        'connect:test',
        'mocha'
    ]);

    grunt.registerTask('build', [
        'clean:dist',
        'bower:install',
        'coffee',
        'compass:dist',
        'useminPrepare',
        'requirejs',
        'concat',
        'cssmin',
        'uglify',
        'copy',
        'usemin'
    ]);

    grunt.registerTask('default', [
        'test',
        'build'
    ]);
};
