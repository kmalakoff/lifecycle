````
Lifecycle.js provides conventions and helpers to manage the life cycles of Javascript instances.
````

## LC.own/LC.disown
Handles individual objects, arrays, and object properties that comply with some lifecycle conventions:

* clone() and destroy()
* retain() and release()
* clone() and Javascript memory management
* plain old JSON

### Examples:

```javascript
var an_object = new Object(); var owned_copy_object = LC.own(an_object); LC.disown(an_object);
var an_array = [new Object(), ‘hello’, new Object()]; var owned_copy_array = LC.own(an_array); LC.disown(an_array);
var an_object = {one: new Object(), two: new Object(), three: ‘there’}; var owned_copy_object = LC.own(an_object, {properties:true}); LC.disown(an_object);
```

## LC.RefCountable
Very basic class (following Coffeescript construction) for a reference countable class.

### Examples:

```coffeescript
class MyClass extends LC.RefCountable
  constructor: ->
    super
    @is_alive = true
  _destroy: ->
    @is_alive = false

instance = new MyClass()  # ref_count = 1
instance.retain()         # ref_count = 2
instance.release()        # ref_count = 1
instance.release()        # ref_count = 0 and _destroy() called
```
