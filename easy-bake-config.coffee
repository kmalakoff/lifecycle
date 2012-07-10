module.exports =
  library:
    join: 'lifecycle.js'
    compress: true
    files: 'src/**/*.coffee'
    _build:
      commands: [
        'cp lifecycle.js packages/npm/lifecycle.js'
        'cp lifecycle.min.js packages/npm/lifecycle.min.js'
        'cp lifecycle.js packages/nuget/Content/Scripts/lifecycle.js'
        'cp lifecycle.min.js packages/nuget/Content/Scripts/lifecycle.min.js'
      ]

  tests:
    _build:
      output: 'build'
      directories: [
        'test/core'
      ]
      commands: [
        'mbundle test/packaging/bundle-config.coffee'
      ]
    _test:
      command: 'phantomjs'
      runner: 'phantomjs-qunit-runner.js'
      files: '**/*.html'
      directories: [
        'test/core'
        'test/packaging'
      ]
