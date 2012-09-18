###
  Lifecycle.js 1.0.2
  (c) 2011, 2012 Kevin Malakoff - http://kmalakoff.github.com/json-serialize/
  License: MIT (http://www.opensource.org/licenses/mit-license.php)

 Note: some 'extend'-related code from Backbone.js is repeated in this file.
 Please see the following for details on Backbone.js and its licensing:
   https:github.com/documentcloud/backbone/blob/master/LICENSE
###

# export or create Lifecycle namespace
LC = @LC = if (typeof(exports) != 'undefined') then exports else {}
LC.VERSION = "1.0.2"

################HELPERS - BEGIN#################
isArray = (obj) ->
  obj.constructor is Array

copyProps = (dest, source) ->
  (dest[key] = value) for key, value of source
  return dest

# From Backbone.js (https:github.com/documentcloud/backbone)
`// Shared empty constructor function to aid in prototype-chain creation.
var ctor = function(){};

// Helper function to correctly set up the prototype chain, for subclasses.
// Similar to 'goog.inherits', but uses a hash of prototype properties and
// class properties to be extended.
var inherits = function(parent, protoProps, staticProps) {
  var child;

  // The constructor function for the new subclass is either defined by you
  // (the "constructor" property in your extend definition), or defaulted
  // by us to simply call the parent's constructor.
  if (protoProps && protoProps.hasOwnProperty('constructor')) {
    child = protoProps.constructor;
  } else {
    child = function(){ parent.apply(this, arguments); };
  }

  // Inherit class (static) properties from parent.
  copyProps(child, parent);

  // Set the prototype chain to inherit from parent, without calling
  // parent's constructor function.
  ctor.prototype = parent.prototype;
  child.prototype = new ctor();

  // Add prototype properties (instance properties) to the subclass,
  // if supplied.
  if (protoProps) copyProps(child.prototype, protoProps);

  // Add static properties to the constructor function, if supplied.
  if (staticProps) copyProps(child, staticProps);

  // Correctly set child's 'prototype.constructor'.
  child.prototype.constructor = child;

  // Set a convenience property in case the parent's prototype is needed later.
  child.__super__ = parent.prototype;

  return child;
};

// The self-propagating extend function that BacLCone classes use.
var extend = function (protoProps, classProps) {
  var child = inherits(this, protoProps, classProps);
  child.extend = this.extend;
  return child;
};
`

################HELPERS - END#################

# Deduces the type of ownership of an item and if available, it retains it (reference counted) or clones it.
# <br/>**Options:**<br/>
# * `properties` - used to disambigate between owning an object and owning each property.<br/>
# * `share_collection` - used to disambigate between owning a collection's items (share) and cloning a collection (don't share).
# * `prefer_clone` - used to disambigate when both retain and clone exist. By default retain is prefered (eg. sharing for lower memory footprint).
LC.own = (obj, options) ->
  return obj  if not obj or (typeof (obj) isnt "object")
  options or (options = {})

  # own each item in the array
  if isArray(obj)
    if options.share_collection
      LC.own(value, {prefer_clone: options.prefer_clone}) for value in obj
      return obj
    else
      clone = []
      clone.push(LC.own(value, {prefer_clone: options.prefer_clone})) for value in obj
      return clone

  # own each property in an object
  else if options.properties
    if options.share_collection
      LC.own(value, {prefer_clone: options.prefer_clone}) for key, value of obj
      return obj
    else
      clone = {}
      (clone[key] = LC.own(value, {prefer_clone: options.prefer_clone})) for key, value of obj
      return clone

  # use retain function
  else if obj.retain
    return if options.prefer_clone and obj.clone then obj.clone() else obj.retain()

  # use clone function
  else if obj.clone
    return obj.clone()

  return obj

# Deduces the type of ownership of an item and if available, it releases it (reference counted) or destroys it.
# <br/>**Options:**<br/>
# * `properties` - used to disambigate between owning an object and owning each property.<br/>
# * `clear_values` - used to disambigate between clearing disowned items and removing them (by default, they are removed).
# * `remove_values` - used to indicate that the values should be disowned and removed from the collections.
LC.disown = (obj, options={}) ->
  return obj  if not obj or (typeof (obj) isnt "object")

  # disown each item in the array
  if isArray(obj)
    if options.clear_values
      (LC.disown(value, {clear_values: options.clear_values}); obj[index]=null) for index, value of obj
    else
      LC.disown(value, {remove_values: options.remove_values}) for value in obj
      obj.length = 0  if options.remove_values

  # disown each property in an object
  else if options.properties
    if options.clear_values
      (LC.disown(value, {clear_values: options.clear_values}); obj[key]=null) for key, value of obj
    else
      (LC.disown(value, {remove_values: options.remove_values}); delete obj[key]) for key, value of obj

  # use release function
  else if obj.release
    obj.release()

  # use destroy function
  else if obj.destroy
    obj.destroy()

  return obj

# A simple reference counting class using Coffeescript class construction or JavaScript extend({}) .
# * __destroy() - override for custom cleanup when all references are released. Note: this function is __destroy instead of _destroy due to an incompatibility with a Knockout convention (https:github.com/kmalakoff/knocLCack/pull/17)
class LC.RefCountable
  @extend = extend # from BacLCone non-Coffeescript inheritance (use "LC.RefCountable_RCBase.extend({})" in Javascript instead of "class MyClass extends LC.RefCountable")

  constructor: ->
    @__LC or= {}
    @__LC.ref_count = 1

  __destroy: -> # NOOP

  # reference counting
  retain: ->
    throw "RefCountable: ref_count is corrupt: #{@__LC.ref_count}" if (@__LC.ref_count <= 0)
    @__LC.ref_count++
    return @

  release: ->
    throw "RefCountable: ref_count is corrupt: #{@__LC.ref_count}" if (@__LC.ref_count <= 0)
    @__LC.ref_count--
    @__destroy() unless @__LC.ref_count
    return @

  refCount: -> return @__LC.ref_count