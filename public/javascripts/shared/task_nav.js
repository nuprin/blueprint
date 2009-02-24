var TaskNavigation = {
  getSelectedTaskId: function() {
    return $(".cursor").attr("task_id");
  },
  open: function() {
    url = $(".cursor td:eq(1) a");
    if (0 < url.length) {
      location.href = url.get(0).href
    }
  },  
  edit: function() {
    id = TaskNavigation.getSelectedTaskId();
    location.href = "/tasks/" + id + "/edit"
  },
  defer: function() {
    id = TaskNavigation.getSelectedTaskId();
    Tasks.parkUntil(id);
  },
  park: function() {
    $(".cursor .park_task_link").click();
  },
  complete: function() {
    $(".cursor .task_complete_form").submit();
  },
  up: function() {
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
  down: function() {
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
  setup: function() {
    $(document.body).shortkeys({
      'Enter': TaskNavigation.open,
      'j':     TaskNavigation.down,
      'Down':  TaskNavigation.down,
      'k':     TaskNavigation.up,
      'Up':    TaskNavigation.up,
      'o':     TaskNavigation.open,
      'e':     TaskNavigation.edit,
      'd':     TaskNavigation.defer,
      'p':     TaskNavigation.park,
      'x':     TaskNavigation.complete,
    }, {moreKeys: {
      'Enter': 13,
      'Up':    38,
      'Down':  40
    }})
  }
}

$(function() {
  TaskNavigation.setup();
  // $(document).keydown(function(e){console.log(e.keyCode);});
});
