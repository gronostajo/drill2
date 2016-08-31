var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('DrillApp').service('Pipeline', function() {
  var Pipeline;
  return Pipeline = (function() {
    Pipeline.prototype.log = [];

    function Pipeline(data) {
      this.data = data;
      this._logAppender = bind(this._logAppender, this);
      return;
    }

    Pipeline.prototype._logAppender = function(str) {
      return this.log.push(str);
    };

    Pipeline.prototype.apply = function(func) {
      this.data = func(this.data, this._logAppender);
      return this;
    };

    Pipeline.prototype.map = function(func) {
      var item;
      if (!angular.isArray(this.data)) {
        throw new Error('Pipeline content is not an array');
      }
      this.data = (function() {
        var i, len, ref, results;
        ref = this.data;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          item = ref[i];
          results.push(func(item, this._logAppender));
        }
        return results;
      }).call(this);
      return this;
    };

    Pipeline.prototype.filter = function(func) {
      if (!angular.isArray(this.data)) {
        throw new Error('Pipeline content is not an array');
      }
      this.data = this.data.filter((function(_this) {
        return function(item) {
          return func(item, _this._logAppender);
        };
      })(this));
      return this;
    };

    Pipeline.prototype.get = function() {
      return this.data;
    };

    Pipeline.prototype.getLog = function() {
      return this.log.slice(0);
    };

    return Pipeline;

  })();
});
