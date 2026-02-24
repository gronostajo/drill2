angular.module('DrillApp').service('Pipeline', function() {
  var Pipeline;
  return Pipeline = class Pipeline {
    constructor(data) {
      this._logAppender = this._logAppender.bind(this);
      this.data = data;
      this.log = [];
    }

    _logAppender(str) {
      return this.log.push(str);
    }

    apply(func) {
      this.data = func(this.data, this._logAppender);
      return this;
    }

    map(func) {
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
    }

    filter(func) {
      if (!angular.isArray(this.data)) {
        throw new Error('Pipeline content is not an array');
      }
      this.data = this.data.filter((item) => {
        return func(item, this._logAppender);
      });
      return this;
    }

    get() {
      return this.data;
    }

    getLog() {
      return this.log.slice(0);
    }

  };
});
