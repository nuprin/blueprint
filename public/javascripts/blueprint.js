// TODO [chris]: This should be refactored into a plugin.
var KeyboardShortcuts = {
  setupFields: function() {
    $('input[type=text],textarea').focus(function() {
      $(document.body).addClass("typing");
    });
    $('input[type=text],textarea').blur(function() {
      $(document.body).removeClass("typing");
    });
  },
  setup: function() {
    this.setupFields();
    $(window).keydown(function(event) {
      if (!$(document.body).hasClass("typing")) {
        if (user.keyboard.character() == "¿") {
          event.preventDefault();
          $("#q").focus();
        }
        if (user.keyboard.character() == "A") {
          event.preventDefault();
          $(".quick_add_link:eq(0)").trigger("click");
        }
      }
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
