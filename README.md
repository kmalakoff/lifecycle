````
Lifecycle.js provides conventions and helpers to manage the life cycles of Javascript instances.
````

You can get the library here:

* Development version: https://github.com/kmalakoff/lifecycle/raw/master/lifecycle.js
* Production version: https://github.com/kmalakoff/lifecycle/raw/master/lifecycle.min.js

Introduction
------------
If you need to write code that manages the lifecycle of some javascript objects, but you don't know ahead of time what type of lifecycle model they implement, Lifecycle.js is for you!

A good example of this is [Backbone.Articulation][0]. Backbone.Articulation will reconstruct instances of Dates or custom classes within you Backbone.Model's attributes irregardless of what lifecycle model they use (as long as they use one of the known conventions!)

[0]: https://github.com/kmalakoff/backbone-articulation

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

# Release Notes

###1.0.1

- converted back to CoffeeScript

- build using easy-bake

- added packaging tests

- added extend() functionality for JavaScript and CoffeeScript class usability

- changed convention from _destroy() to __destroy() given that some libraries (like KnockoutJS) use _destroy for other purposes

- removed Lifecycle alias


Building, Running and Testing the library
-----------------------

###Installing:

1. install node.js: http://nodejs.org
2. install node packages: 'npm install'

###Commands:

Look at: https://github.com/kmalakoff/easy-bake
