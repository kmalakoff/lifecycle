Please refer to the following release notes when upgrading your version of Lifecycle.js.

## 1.0.4

* relase with MIT license in package.json: https://github.com/kmalakoff/lifecycle/pull/2

## 1.0.2

* renamed _destroy to __destroy to avoid conflicts.
* added AMD loader.

## 1.0.1

* converted back to CoffeeScript
* build using easy-bake
* added packaging tests
* added extend() functionality for JavaScript and CoffeeScript class usability
* changed convention from _destroy() to __destroy() given that some libraries (like KnockoutJS) use _destroy for other purposes
* removed Lifecycle alias