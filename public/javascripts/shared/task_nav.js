var TaskNavigation = {
  setup: function() {
    $(document.body).shortkeys({
      'j': function() {
        cursor = $("#main_task_list .cursor");
        if (0 == cursor.length) {
          $("#main_task_list tbody tr:first-child").addClass('cursor');
          return;
        }
        next = cursor.next();
        if (0 < next.length) {
          cursor.removeClass('cursor');
          next.addClass('cursor');
          //next.get(0).scrollIntoView(false);
        }
      },
      'k': function() {
        cursor = $("#main_task_list .cursor");
        if (0 == cursor.length) {
          $("#main_task_list tbody tr:first-child").addClass('cursor');
          return;
        }
        prev = cursor.prev();
        if (0 < prev.length) {
          cursor.removeClass('cursor');
          prev.addClass('cursor');
          //prev.get(0).scrollIntoView(true);
        }
      },
      'Enter': function() {
        url = $(".cursor td:eq(1) a");
        if (0 < url.length) {
          location.href = url.get(0).href
        }
      }
    }, {moreKeys: {'Enter':13} })
  }
}

$(function() {
  TaskNavigation.setup();
  //$(document).keydown(function(e){alert(e.keyCode);});
});
