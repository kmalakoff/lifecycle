size = (obj) ->
  result = 0
  result++ for key of obj
  return result

isArray = (obj) ->
  return obj.constructor == Array

clone = (obj) ->
  if isArray(obj)
    result = []
    result.push(obj[key]) for key of obj
    return result
  else
    result = {}
    (result[key]=obj[key] if obj.hasOwnProperty(key)) for key of obj
    return result

###############
# Start Tests
###############
module("Lifecycle.js")

# import Lifecycle
LC = if not window.LC and (typeof(require) isnt 'undefined') then require('lifecycle') else window.LC

test("TEST DEPENDENCY MISSING", ->
  ok(!!LC)
)

test('collections: own and disown', ->
  original = null
  copy = LC.own(original)
  ok(!copy, 'no instance')
  LC.disown(original); LC.disown(copy)

  class CloneDestroy
    @instance_count = 0
    constructor: -> CloneDestroy.instance_count++
    clone: -> return new CloneDestroy()
    destroy: -> CloneDestroy.instance_count--

  CloneDestroy.instance_count = 0
  original = new CloneDestroy()
  equal(CloneDestroy.instance_count, 1, 'cd: 1 instance')
  copy = LC.own(original)
  equal(CloneDestroy.instance_count, 2, 'cd: 2 instances')
  LC.disown(original)
  equal(CloneDestroy.instance_count, 1, 'cd: 1 instance')
  LC.disown(copy)
  equal(CloneDestroy.instance_count, 0, 'cd: 0 instances')

  CloneDestroy.instance_count = 0
  original = [new CloneDestroy(), new CloneDestroy(), new CloneDestroy()]
  equal(CloneDestroy.instance_count, 3, 'cd: 3 instances')
  original_again = LC.own(original, {share_collection:true})
  equal(original_again, original, 'cd: retained existing')
  equal(CloneDestroy.instance_count, 6, 'cd: 6 instances')
  copy = clone(original_again)
  LC.disown(original); LC.disown(copy)
  equal(CloneDestroy.instance_count, 0, 'cd: 0 instances')

  CloneDestroy.instance_count = 0
  original = [new CloneDestroy(), new CloneDestroy(), new CloneDestroy()]
  equal(CloneDestroy.instance_count, 3, 'cd: 3 instances')
  copy = LC.own(original)
  ok(copy isnt original, 'cd: retained existing')
  equal(CloneDestroy.instance_count, 6, 'cd: 6 instances')
  LC.disown(original); LC.disown(copy)
  equal(CloneDestroy.instance_count, 0, 'cd: 0 instances')

  CloneDestroy.instance_count = 0
  original = {one:new CloneDestroy(), two:new CloneDestroy(), three:new CloneDestroy()}
  equal(CloneDestroy.instance_count, 3, 'cd: 3 instances')
  copy = LC.own(original, {properties:true})
  equal(CloneDestroy.instance_count, 6, 'cd: 6 instances')
  LC.disown(original, {properties:true}); LC.disown(copy, {properties:true})
  equal(CloneDestroy.instance_count, 0, 'cd: 0 instances')

  CloneDestroy.instance_count = 0
  original = [new CloneDestroy(), new CloneDestroy(), new CloneDestroy()]
  LC.disown(original, {clear_values:true})
  equal(original.length, 3, 'cd: 3 instances')

  class RetainRelease
    RetainRelease.instance_count = 0
    constructor: ->
      @retain_count=1
      RetainRelease.instance_count++
    retain: ->
      @retain_count++
      return @
    release: ->
      @retain_count--
      RetainRelease.instance_count-- if (@retain_count is 0)
      return @

  RetainRelease.instance_count = 0
  original = new RetainRelease()
  equal(RetainRelease.instance_count, 1, 'rr: 1 instance')
  equal(original.retain_count, 1, 'rr: 1 retain')
  original_retained = LC.own(original)
  equal(RetainRelease.instance_count, 1, 'rr: 1 instances')
  ok(original_retained==original, 'rr: same object')
  equal(original.retain_count, 2, 'rr: 2 retains')
  LC.disown(original); LC.disown(original_retained)
  equal(RetainRelease.instance_count, 0, 'rr: 0 instances')
  equal(original.retain_count, 0, 'rr: 0 retains')

  RetainRelease.instance_count = 0
  original = [new RetainRelease(), new RetainRelease(), new RetainRelease()]
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  equal(original[0].retain_count, 1, 'rr: 1 retain')
  original_retained = LC.own(original)
  ok(original_retained isnt original, 'rr: different object')
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  equal(original[0].retain_count, 2, 'rr: 2 retains')
  LC.disown(original, {clear_values:false, remove_values:true})
  equal(original.length, 0, 'rr: 0 values')
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  equal(original_retained[0].retain_count, 1, 'rr: 1 retain')
  LC.disown(original_retained)
  equal(RetainRelease.instance_count, 0, 'rr: 0 instances')

  RetainRelease.instance_count = 0
  original = [new RetainRelease(), new RetainRelease(), new RetainRelease()]
  LC.disown(original, {clear_values:true})
  equal(original.length, 3, 'rr: 3 values')

  RetainRelease.instance_count = 0
  original = {one:new RetainRelease(), two:new RetainRelease(), three:new RetainRelease()}
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  equal(original.one.retain_count, 1, 'rr: 1 retain')
  original_again = LC.own(original, {share_collection:true, properties:true})
  ok(original_again is original, 'rr: different object')
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  copy = clone(original_again)
  LC.disown(original, {properties:true, clear_values:false, remove_values:true})
  equal(size(original), 0, 'rr: 0 key/values')
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  LC.disown(copy, {properties:true})
  equal(RetainRelease.instance_count, 0, 'rr: 0 instances')

  RetainRelease.instance_count = 0
  original = {one:new RetainRelease(), two:new RetainRelease(), three:new RetainRelease()}
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  equal(original.one.retain_count, 1, 'rr: 1 retain')
  original_retained = LC.own(original, {share_collection:false, properties:true})
  ok(original_retained isnt original, 'rr: same object')
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  LC.disown(original, {properties:true, clear_values:true})
  equal(size(original), 3, 'rr: 3 key/values')
  equal(RetainRelease.instance_count, 3, 'rr: 3 instances')
  equal(original_retained.one.retain_count, 1, 'rr: 1 retain')
  LC.disown(original_retained, {properties:true})
  equal(RetainRelease.instance_count, 0, 'rr: 0 instances')

  RetainRelease.instance_count = 0
  original = {one:new RetainRelease(), two:new RetainRelease(), three:new RetainRelease()}
  LC.disown(original, {properties:true, clear_values:true})
  equal(size(original), 3, 'rr: 3 instances')

  class RetainReleaseWithClone
    RetainReleaseWithClone.instance_count = 0
    constructor: ->
      @retain_count=1
      RetainReleaseWithClone.instance_count++
    clone: ->
      return new RetainReleaseWithClone()
    retain: ->
      @retain_count++
      return @
    release: ->
      @retain_count--
      RetainReleaseWithClone.instance_count-- if (@retain_count is 0)
      return @

  RetainReleaseWithClone.instance_count = 0
  original = new RetainReleaseWithClone()
  equal(RetainReleaseWithClone.instance_count, 1, 'rr: 1 instance')
  equal(original.retain_count, 1, 'rrc: 1 retain')
  copy = LC.own(original, {prefer_clone:true})   # a clone exists in addition to retain so use it instead of retain
  equal(RetainReleaseWithClone.instance_count, 2, 'rrc: 2 instances')
  ok(copy isnt original, 'rrc: diferent objects')
  ok(original.retain_count, 1, 'rrc: 1 retains')
  equal(copy.retain_count, 1, 'rrc: 1 retains')
  LC.disown(original); LC.disown(copy)
  equal(RetainReleaseWithClone.instance_count, 0, 'rrc: 0 instances')
  equal(original.retain_count, 0, 'rrc: 0 retains')
  equal(copy.retain_count, 0, 'rrc: 0 retains')

  # prefering retain is default, expect same result as RetainRelease
  RetainReleaseWithClone.instance_count = 0
  original = new RetainReleaseWithClone()
  equal(RetainReleaseWithClone.instance_count, 1, 'rrc: 1 instance')
  equal(original.retain_count, 1, 'rrc: 1 retain')
  original_retained = LC.own(original)
  equal(RetainReleaseWithClone.instance_count, 1, 'rrc: 1 instances')
  ok(original_retained is original, 'rrc: same object')
  equal(original.retain_count, 2, 'rrc: 2 retains')
  LC.disown(original); LC.disown(original_retained)
  equal(RetainReleaseWithClone.instance_count, 0, 'rrc: 0 instances')
  equal(original.retain_count, 0, 'rrc: 0 retains')
)

test('ref countable (javascript)', ->

  MyClass = LC.RefCountable.extend({
    constructor: ->
      LC.RefCountable.prototype.constructor.apply(@, arguments)
      @is_alive = true

    __destroy: ->
      @is_alive = false
  })

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