'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
    var directory = require('path').resolve(dir);
    console.log("serving up:", directory)
    return connect.static(directory);
};

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);
  grunt.loadNpmTasks('grunt-generator');
  grunt.loadNpmTasks('grunt-haml');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-exec');

  // configurable paths
  var yeomanConfig = {
    app: 'site',
    dist: 'dist',
    serve: '.tmp',
    basePath: '/choc/'
  };
  yeomanConfig["serveRoot"] = yeomanConfig.serve + yeomanConfig.basePath;

  grunt.initConfig({
    yeoman: yeomanConfig,

    watch: {
      coffee: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee'],
        tasks: ['coffee:serve']
      },
      compass: {
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
        tasks: ['compass']
      },
	    jekyll: {
				files: [
          '<%= yeoman.app %>/{,*/}*.html',
          '<%= yeoman.app %>/{,*/}*.haml'
        ],
				tasks: ['jekyll:serve', 'compass', 'coffee:serve']
			},
      choc: {
        files: ['<%= yeoman.app %>/components/choc/dist/{,*/}/*.{js,coffee}'],
        tasks: ['copy:choc', 'livereload']
      },
      livereload: {
        files: [
          '<%= yeoman.app %>/*.html',
          '{<%= yeoman.serveRoot %>,<%= yeoman.app %>}/{,*/}*.html',
          '{<%= yeoman.serveRoot %>,<%= yeoman.app %>}/styles/{,*/}*.css',
          '{<%= yeoman.serveRoot %>,<%= yeoman.app %>}/scripts/**/*.js',
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
              mountFolder(connect, yeomanConfig.serve),
              mountFolder(connect, yeomanConfig.app)
            ];
          }
        }
      },
      test: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, yeomanConfig.serve),
              mountFolder(connect, 'test')
            ];
          }
        }
      },
      dist: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, yeomanConfig.dist)
            ];
          }
        }
      }
    },
    open: {
      server: {
        path: 'http://localhost:<%= connect.options.port %><%= yeoman.basePath %>'
      }
    },
    clean: {
      dist: ['<%= yeoman.dist %>/*'],
      server: '<%= yeoman.serve %>'
    },
    coffee: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '**/*.coffee',
          dest: '<%= yeoman.dist %>/scripts',
          ext: '.js'
        }]
      },
      serve: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '**/*.coffee',
          dest: '<%= yeoman.serveRoot %>/scripts',
          ext: '.js'
        }]
      }

    },
    compass: {
      options: {
        sassDir: '<%= yeoman.app %>/styles',
        imagesDir: '<%= yeoman.app %>/images',
        relativeAssets: true,
        force: true,
        debugInfo: true,
        require: ['rgbapng', 'animation']
      },
      dist: {
        options: {
          cssDir: '<%= yeoman.dist %>/styles',
          javascriptsDir: '<%= yeoman.dist %>/scripts'
        }
      },
      server: {
        options: {
          debugInfo: true,
          cssDir: '<%= yeoman.serveRoot %>/styles',
          javascriptsDir: '<%= yeoman.serveRoot %>/scripts'
        },
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
            '<%= yeoman.serveRoot %>/styles/{,*/}*.css',
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
      },
      // special copy task since choc is often developed alongside this project
      // this is a lot faster than copying every file in components on every reload
      choc: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>/components/choc/dist',
          dest: '<%= yeoman.serveRoot %>/components/choc/dist',
          src: [ '*.js' ]
        }]
      }
    },
    bower: {
      install: {
      }
    },

    jekyll: {                             // Task
      options: {                          // Universal options
        bundleExec: true,
        src : 'site',
        config: 'site/_config.yml'
      },
      dist: {                             // Target
        options: {                        // Target options
          dest: '<%= yeoman.dist %>'
        }
      },
      serve: {                            // Another target
        options: {
          dest: '<%= yeoman.serveRoot %>',
          drafts: true //,
          // baseurl: "/choc/"
        }
      }
    },

    shell: {
      deployBeta: {
        options: {
          stdout: true,
          stderr: true
        },
        command: 's3cmd sync .tmp/ s3://j0dcwqka8t4jju2.private.choc/ && open "http://j0dcwqka8t4jju2.private.choc.s3-website-us-east-1.amazonaws.com/index.html"'
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
            'coffee:serve',
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
        'coffee:dist',
        'jekyll:dist',
        'compass:dist',
        // 'useminPrepare',
        // 'concat',
        // 'cssmin',
        //'uglify',
        'copy' //,
        // 'usemin'
    ]);

    grunt.registerTask('default', [
        'test',
        'build'
    ]);

    grunt.registerTask('install', [
        'bower:install'
    ]);

    grunt.registerTask('deployBeta', ['shell:deployBeta']);
};
