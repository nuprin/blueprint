var $_callbackStack = [];
var $ = function (fnCallback) {
  var cbs = $_callbackStack;
  cbs.push(fnCallback);
  if (cbs.length == 1) {
    var fireAll = function () {
      while (fn = cbs.pop()) {
        fn();
      }
    };
    google.setOnLoadCallback(fireAll);
  }
};
google.load("jquery", "1.2.6");
google.load("jqueryui", "1.5.2");
