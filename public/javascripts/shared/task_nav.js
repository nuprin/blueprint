var TaskNavigation = {
  getSelectedTaskId: function() {
    return $(".cursor").attr("task_id");
  },
  open: function() {
    url = $(".cursor td:eq(1) a");
    if (0 < url.length) {
      location.href = url.get(0).href;
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
  parkOrPrioritize: function() {
    $(".cursor .park_task_link").add(".cursor .prioritize_task_link").click();
  },
  moveToTop: function() {
    $(".cursor .task_move_to_top_link").click();
  },
  complete: function() {
    $(".cursor .task_complete_form").submit();
  },
  deleteTask: function() {
    $(".cursor .task_delete_link").click();
  },
  up: function() {
    cursor = $(".cursor");
    if (0 == cursor.length) {
      $(".task_list:eq(0) tbody tr:first-child").addClass('cursor');
      return;
    }
    prev = cursor.prev();
    if (0 < prev.length) {
      cursor.removeClass('cursor');
      prev.addClass('cursor');
    }
  },
  down: function() {
    cursor = $(".cursor");
    if (0 == cursor.length) {
      $(".task_list:eq(0) tbody tr:first-child").addClass('cursor');
      return;
    }
    next = cursor.next();
    if (0 < next.length) {
      cursor.removeClass('cursor');
      next.addClass('cursor');
    }
  },
  setupSelection: function() {
    $(".task_list tbody tr").click(function() {
      $(".task_list tr").removeClass('cursor');
      $(this).addClass('cursor');
    })
  },
  setup: function() {
    this.setupSelection();
    $(document.body).shortkeys({
      'Enter':   TaskNavigation.open,
      'j':       TaskNavigation.down,
      'Down':    TaskNavigation.down,
      'k':       TaskNavigation.up,
      'Up':      TaskNavigation.up,
      'o':       TaskNavigation.open,
      'e':       TaskNavigation.edit,
      'd':       TaskNavigation.defer,
      'p':       TaskNavigation.parkOrPrioritize,
      't':       TaskNavigation.moveToTop,
      'x':       TaskNavigation.complete,
      'Shift+1': TaskNavigation.deleteTask
    }, {moreKeys: {
      'Enter': 13,
      'Shift': 16,
      'Up':    38,
      'Down':  40
    }})
  }
}

$(function() {
  TaskNavigation.setup();
  // $(document).keydown(function(e){console.log(e.keyCode);});
});
