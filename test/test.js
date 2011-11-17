var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
}, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

var size = function(obj) {
  var size = 0;
  for(var key in obj) {size++;}
  return size;
}

var isArray = function(obj) {
  return obj.constructor == Array;
};

var clone = function(obj) {
  if (isArray(obj)) {
    var clone = [];
    for(var key in obj) {clone.push(obj[key]);}
    return clone;
  }
  else {
    var clone = {};
    for(var key in obj) {if (obj.hasOwnProperty(key)) clone[key]=obj[key];}
    return clone;
  }
}

var root = this;

$(document).ready(function() {
  module("Lifecycle.js");

  test('collections: own and disown', function() {
    var original, original_again, copy;

    original = null;
    copy = LC.own(original);
    ok(!copy, 'no instance');
    LC.disown(original); LC.disown(copy);

    CloneDestroy = (function() {
      CloneDestroy.instance_count = 0;
      function CloneDestroy() { CloneDestroy.instance_count++; }
      CloneDestroy.prototype.clone = function() { return new CloneDestroy() };
      CloneDestroy.prototype.destroy = function() { CloneDestroy.instance_count--; };
      return CloneDestroy;
    })();

    CloneDestroy.instance_count = 0; original = new CloneDestroy();
    equal(CloneDestroy.instance_count, 1, 'cd: 1 instance');
    copy = LC.own(original);
    equal(CloneDestroy.instance_count, 2, 'cd: 2 instances');
    LC.disown(original);
    equal(CloneDestroy.instance_count, 1, 'cd: 1 instance');
    LC.disown(copy);
    equal(CloneDestroy.instance_count, 0, 'cd: 0 instances');

    CloneDestroy.instance_count = 0; original = [new CloneDestroy(), new CloneDestroy(), new CloneDestroy()];
    equal(CloneDestroy.instance_count, 3, 'cd: 3 instances');
    original_again = LC.own(original, {share_collection:true});
    ok(original_again===original, 'cd: retained existing');
    equal(CloneDestroy.instance_count, 6, 'cd: 6 instances');
    copy = clone(original_again)
    LC.disown(original); LC.disown(copy);
    equal(CloneDestroy.instance_count, 0, 'cd: 0 instances');

    CloneDestroy.instance_count = 0; original = [new CloneDestroy(), new CloneDestroy(), new CloneDestroy()];
    equal(CloneDestroy.instance_count, 3, 'cd: 3 instances');
    copy = LC.own(original);
    ok(copy!==original, 'cd: retained existing');
    equal(CloneDestroy.instance_count, 6, 'cd: 6 instances');
    LC.disown(original); LC.disown(copy);
    equal(CloneDestroy.instance_count, 0, 'cd: 0 instances');

    CloneDestroy.instance_count = 0; original = {one:new CloneDestroy(), two:new CloneDestroy(), three:new CloneDestroy()};
    equal(CloneDestroy.instance_count, 3, 'cd: 3 instances');
    copy = LC.own(original, {properties:true});
    equal(CloneDestroy.instance_count, 6, 'cd: 6 instances');
    LC.disown(original, {properties:true}); LC.disown(copy, {properties:true});
    equal(CloneDestroy.instance_count, 0, 'cd: 0 instances');

    CloneDestroy.instance_count = 0; original = [new CloneDestroy(), new CloneDestroy(), new CloneDestroy()];
    LC.disown(original, {clear_values:true});
    equal(original.length, 3, 'cd: 3 instances');

    RetainRelease = (function() {
      RetainRelease.instance_count = 0;
      function RetainRelease() { this.retain_count=1; RetainRelease.instance_count++ }
      RetainRelease.prototype.retain = function() { this.retain_count++; };
      RetainRelease.prototype.release = function() { this.retain_count--; if (this.retain_count==0) RetainRelease.instance_count--; };
      return RetainRelease;
    })();

    RetainRelease.instance_count = 0; original = new RetainRelease();
    equal(RetainRelease.instance_count, 1, 'rr: 1 instance');
    equal(original.retain_count, 1, 'rr: 1 retain');
    original_retained = LC.own(original);
    equal(RetainRelease.instance_count, 1, 'rr: 1 instances');
    ok(original_retained==original, 'rr: same object');
    equal(original.retain_count, 2, 'rr: 2 retains');
    LC.disown(original); LC.disown(original_retained);
    equal(RetainRelease.instance_count, 0, 'rr: 0 instances');
    equal(original.retain_count, 0, 'rr: 0 retains');

    RetainRelease.instance_count = 0; original = [new RetainRelease(), new RetainRelease(), new RetainRelease()];
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    equal(original[0].retain_count, 1, 'rr: 1 retain');
    original_retained = LC.own(original);
    ok(original_retained!==original, 'rr: different object');
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    equal(original[0].retain_count, 2, 'rr: 2 retains');
    LC.disown(original, {clear_values:false, remove_values:true});
    equal(original.length, 0, 'rr: 0 values');
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    equal(original_retained[0].retain_count, 1, 'rr: 1 retain');
    LC.disown(original_retained);
    equal(RetainRelease.instance_count, 0, 'rr: 0 instances');

    RetainRelease.instance_count = 0; original = [new RetainRelease(), new RetainRelease(), new RetainRelease()];
    LC.disown(original, {clear_values:true});
    equal(original.length, 3, 'rr: 3 values');

    RetainRelease.instance_count = 0; original = {one:new RetainRelease(), two:new RetainRelease(), three:new RetainRelease()};
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    equal(original.one.retain_count, 1, 'rr: 1 retain');
    original_again = LC.own(original, {share_collection:true, properties:true});
    ok(original_again===original, 'rr: different object');
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    copy = clone(original_again);
    LC.disown(original, {properties:true, clear_values:false, remove_values:true})
    equal(size(original), 0, 'rr: 0 key/values');
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    LC.disown(copy, {properties:true});
    equal(RetainRelease.instance_count, 0, 'rr: 0 instances');

    RetainRelease.instance_count = 0; original = {one:new RetainRelease(), two:new RetainRelease(), three:new RetainRelease()};
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    equal(original.one.retain_count, 1, 'rr: 1 retain');
    original_retained = LC.own(original, {share_collection:false, properties:true});
    ok(original_retained!==original, 'rr: same object');
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    LC.disown(original, {properties:true, clear_values:true})
    equal(size(original), 3, 'rr: 3 key/values');
    equal(RetainRelease.instance_count, 3, 'rr: 3 instances');
    equal(original_retained.one.retain_count, 1, 'rr: 1 retain');
    LC.disown(original_retained, {properties:true});
    equal(RetainRelease.instance_count, 0, 'rr: 0 instances');

    RetainRelease.instance_count = 0; original = {one:new RetainRelease(), two:new RetainRelease(), three:new RetainRelease()};
    LC.disown(original, {properties:true, clear_values:true});
    equal(size(original), 3, 'rr: 3 instances');

    RetainReleaseWithClone = (function() {
      RetainReleaseWithClone.instance_count = 0;
      function RetainReleaseWithClone() { this.retain_count=1; RetainReleaseWithClone.instance_count++; }
      RetainReleaseWithClone.prototype.clone = function() { return new RetainReleaseWithClone(); };
      RetainReleaseWithClone.prototype.retain = function() { this.retain_count++; };
      RetainReleaseWithClone.prototype.release = function() { this.retain_count--; if (this.retain_count==0) RetainReleaseWithClone.instance_count--; };
      return RetainReleaseWithClone;
    })();

    RetainReleaseWithClone.instance_count = 0; original = new RetainReleaseWithClone();
    equal(RetainReleaseWithClone.instance_count, 1, 'rr: 1 instance');
    equal(original.retain_count, 1, 'rrc: 1 retain');
    copy = LC.own(original, {prefer_clone:true});   // a clone exists in addition to retain so use it instead of retain
    equal(RetainReleaseWithClone.instance_count, 2, 'rrc: 2 instances');
    ok(copy!=original, 'rrc: diferent objects');
    ok(original.retain_count, 1, 'rrc: 1 retains');
    equal(copy.retain_count, 1, 'rrc: 1 retains');
    LC.disown(original); LC.disown(copy);
    equal(RetainReleaseWithClone.instance_count, 0, 'rrc: 0 instances');
    equal(original.retain_count, 0, 'rrc: 0 retains');
    equal(copy.retain_count, 0, 'rrc: 0 retains');

    // prefering retain is default, expect same result as RetainRelease
    RetainReleaseWithClone.instance_count = 0; original = new RetainReleaseWithClone();
    equal(RetainReleaseWithClone.instance_count, 1, 'rrc: 1 instance');
    equal(original.retain_count, 1, 'rrc: 1 retain');
    original_retained = LC.own(original);
    equal(RetainReleaseWithClone.instance_count, 1, 'rrc: 1 instances');
    ok(original_retained==original, 'rrc: same object');
    equal(original.retain_count, 2, 'rrc: 2 retains');
    LC.disown(original); LC.disown(original_retained);
    equal(RetainReleaseWithClone.instance_count, 0, 'rrc: 0 instances');
    equal(original.retain_count, 0, 'rrc: 0 retains');
  });

  test('collections: own and disown', function() {

    MyClass = (function() {
      __extends(MyClass, LC.RefCountable);
      function MyClass() {
        MyClass.__super__.constructor.apply(this, arguments);
        this.is_alive = true;
      }
      MyClass.prototype._destroy = function() {
        this.is_alive = false;
      };
      return MyClass;
    })();

    var instance = new MyClass();
    equal(instance.is_alive, true, 'is alive');

    equal(instance.refCount(), 1, '1 reference');
    equal(instance.retain(), instance, 'chaining');
    equal(instance.refCount(), 2, '2 references');
    equal(instance.retain(), instance, 'chaining');
    equal(instance.refCount(), 3, '3 references');
    equal(instance.is_alive, true, 'is alive');

    equal(instance.release(), instance, 'chaining');
    equal(instance.refCount(), 2, '2 references');
    equal(instance.is_alive, true, 'is alive');
    equal(instance.retain(), instance, 'chaining');
    equal(instance.refCount(), 3, '3 references');
    equal(instance.is_alive, true, 'is alive');

    equal(instance.release(), instance, 'chaining');
    equal(instance.refCount(), 2, '2 references');
    equal(instance.release(), instance, 'chaining');
    equal(instance.refCount(), 1, '1 reference');
    equal(instance.is_alive, true, 'is alive');

    equal(instance.release(), instance, 'chaining');
    equal(instance.refCount(), 0, '0 references');
    equal(instance.is_alive, false, 'is gone');

    raises(function(){instance.release()}, Error, 'LC.RefCounting: ref_count is corrupt');
    equal(instance.is_alive, false, 'is gone');
  });
});
