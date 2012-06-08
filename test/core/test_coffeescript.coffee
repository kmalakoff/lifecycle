$(document).ready(->
  module("Lifecycle.js")

  # import Lifecycle
  LC = if !window.LC && (typeof require != 'undefined') then require('lifecycle') else window.LC

  test("TEST DEPENDENCY MISSING", ->
    ok(!!LC)
  )

  test('ref countable (coffeescript)', ->

    class MyClass extends LC.RefCountable
      constructor: ->
        super
        @is_alive = true

      __destroy: ->
        @is_alive = false

    instance = new MyClass()
    equal(instance.is_alive, true, 'is alive')

    equal(instance.refCount(), 1, '1 reference')
    equal(instance.retain(), instance, 'chaining')
    equal(instance.refCount(), 2, '2 references')
    equal(instance.retain(), instance, 'chaining')
    equal(instance.refCount(), 3, '3 references')
    equal(instance.is_alive, true, 'is alive')

    equal(instance.release(), instance, 'chaining')
    equal(instance.refCount(), 2, '2 references')
    equal(instance.is_alive, true, 'is alive')
    equal(instance.retain(), instance, 'chaining')
    equal(instance.refCount(), 3, '3 references')
    equal(instance.is_alive, true, 'is alive')

    equal(instance.release(), instance, 'chaining')
    equal(instance.refCount(), 2, '2 references')
    equal(instance.release(), instance, 'chaining')
    equal(instance.refCount(), 1, '1 reference')
    equal(instance.is_alive, true, 'is alive')

    equal(instance.release(), instance, 'chaining')
    equal(instance.refCount(), 0, '0 references')
    equal(instance.is_alive, false, 'is gone')

    raises((->instance.release()), null, 'LC.RefCounting: ref_count is corrupt')
    equal(instance.is_alive, false, 'is gone')
  )
)