// TODO [chris]: This should be refactored into a plugin.
var KeyboardShortcuts = {
  setup: function() {
    $(document.body).shortkeys({
      "a": function() {
        $(".quick_add_link:eq(0)").trigger("click");      
      },
      'i': function() {
        location.href = "/projects/all";
      },
      "n": function() {
        location.href = "/tasks/new"
      },
      's': function() {
        location.href = "/users/" + VIEWER_ID + "/subscribed?status=prioritized"
      },
      'y': function() {
        location.href = "/";
      },
      '¿': function() {
        $("#q").focus();
      }
    })
    // TODO: MOve this over to shortkeys when it supports the concept of a
    // "universal" shortcut, a shortcut that works regardless of whether you're
    // on a form field or not.
    $(window).keydown(function(event) {
      if (user.keyboard.character() == "esc") {
        event.preventDefault();
        $("#task_title").blur();
        $(".quick_cancel_link:eq(0)").trigger("click")
      }
    })
  }
}

$(function() {
  $('ul.sf-menu').superfish({
    delay:      0,
    speed:      'fast'
  });
  $("textarea").keydown(function(event) {
    if (user.keyboard.character() == "enter") {
      $(this).height($(this).height() + 20);
    }
  });
  KeyboardShortcuts.setup();
})
