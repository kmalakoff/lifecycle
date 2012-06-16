module.exports =
  library:
    join: 'lifecycle.js'
    compress: true
    files: 'src/**/*.coffee'
    modes:
      build:
        commands: [
          'cp lifecycle.js packages/npm/lifecycle.js'
          'cp lifecycle.min.js packages/npm/lifecycle.min.js'
        ]

  tests:
    output: 'build'
    directories: [
      'test/core'
      'test/packaging'
    ]
    modes:
      build:
        bundles:
          'test/packaging/build/bundle.js':
            lifecycle: 'lifecycle.js'
        no_files_ok: 'test/packaging'
      test:
        command: 'phantomjs'
        runner: 'phantomjs-qunit-runner.js'
        files: '**/*.html'