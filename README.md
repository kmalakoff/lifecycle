[![Build Status](https://secure.travis-ci.org/kmalakoff/lifecycle.png)](http://travis-ci.org/kmalakoff/lifecycle#master)

Lifecycle.js provides conventions and helpers to manage the life cycles of Javascript instances.

#Download Latest (1.0.4):

Please see the [release notes](https://github.com/kmalakoff/lifecycle/blob/master/RELEASE_NOTES.md) for upgrade pointers.

* [Development version](https://raw.github.com/kmalakoff/lifecycle/1.0.4/lifecycle.js)
* [Production version](https://raw.github.com/kmalakoff/lifecycle/1.0.4/lifecycle.min.js)

###Module Loading

Lifecycle.js is compatible with RequireJS, CommonJS, Brunch and AMD module loading. Module names:

* 'lifecycle' - lifecycle.js.

Introduction
------------
If you need to write code that manages the lifecycle of some javascript objects, but you don't know ahead of time what type of lifecycle model they implement, Lifecycle.js is for you!

A good example of this is [Backbone.Articulation](https://github.com/kmalakoff/backbone-articulation). Backbone.Articulation will reconstruct instances of Dates or custom classes within you Backbone.Model's attributes irregardless of what lifecycle model they use (as long as they use one of the known conventions!)

# LC.own and LC.disown
Manages the lifecycle of individual instances, objects, arrays, and object properties that comply with some lifecycle conventions:

* clone() and destroy()
* retain() and release()
* clone() and Javascript memory management
* plain old JSON

### Examples:

Run time determination of the correct lifecycle for an instance:

```coffeescript
instance = new MyClass()
owned_copy_instance = LC.own(instance)       # you don't need to know whether MyClass needs to get cloned, retained, etc
...
LC.disown(owned_copy_instance)               # you don't need to know whether MyClass needs to get destroyed, released, etc
```

It also works for Javascript collection types:

```coffeescript
# works for arrays containing instances or primitive types
an_array = [new Object(), ‘hello’, new Object()]
owned_copy_array = LC.own(an_array)
...
LC.disown(an_array)

# works for objects whose properties contain instances or primitive types
an_object = {one: new Object(), two: new Object(), three: ‘there’}
owned_copy_object = LC.own(an_object, {properties:true})
...
LC.disown(an_object);
```

## LC.RefCountable
Very basic implementation following the Coffeescript class pattern for a reference countable class.

### Examples:

CoffeeScript classes:

```coffeescript
class MyClass extends LC.RefCountable
  constructor: ->
    super
    @is_alive = true
  __destroy: ->
    @is_alive = false

instance = new MyClass()  # ref_count = 1
instance.retain()         # ref_count = 2
instance.release()        # ref_count = 1
instance.release()        # ref_count = 0 and __destroy() called
```

JavaScript classes using extend:

```javascript
var MyClass = LC.RefCountable.extend({
  constructor: function() {
    LC.RefCountable.prototype.constructor.apply(this, arguments);
    this.is_alive = true;
  },
  __destroy: function() {
    this.is_alive = false;
  }
});

var instance = new MyClass();   // ref_count = 1
instance.retain();              // ref_count = 2
instance.release();             // ref_count = 1
instance.release();             // ref_count = 0 and __destroy() called
```

Building, Running and Testing the library
-----------------------

###Installing:

1. install node.js: http://nodejs.org
2. install node packages: 'npm install'

###Commands:

Look at: https://github.com/kmalakoff/easy-bake