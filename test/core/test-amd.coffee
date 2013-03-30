try
  require.config({
    paths:
      'lifecycle': "../../lifecycle"
  })

  # library and dependencies
  require ['lifecycle', 'qunit_test_runner'], (lc, runner) ->
    window.LC = null # force each test to require dependencies synchronously
    require ['./build/test'], -> runner.start()