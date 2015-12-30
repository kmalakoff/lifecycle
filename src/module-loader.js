/*
  Lifecycle.js 1.0.4
  (c) 2011, 2012 Kevin Malakoff - http://kmalakoff.github.com/json-serialize/
  License: MIT (http://www.opensource.org/licenses/mit-license.php)

 Note: some 'extend'-related code from Backbone.js is repeated in this file.
 Please see the following for details on Backbone.js and its licensing:
   https:github.com/documentcloud/backbone/blob/master/LICENSE
*/
(function() {
  return (function(factory) {
    // AMD
    if (typeof define === 'function' && define.amd) {
      return define('lifecycle', factory);
    }
    // CommonJS/NodeJS or No Loader
    else {
      return factory.call(this);
    }
  })(function() {'__REPLACE__'; return LC;});
}).call(this);