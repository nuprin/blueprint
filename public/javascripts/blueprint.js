// TODO [chris]: This should be refactored into a plugin.
var KeyboardShortcuts = {
  setup: function() {
    $(document.body).shortkeys({
      'a': function() {
        $(".quick_add_link:eq(0)").trigger("click");
      },
      'b': function() {
        location.href = "/bugs";
      },
      'i': function() {
        location.href = "/projects/all";
      },
      'n': function() {
        location.href = "/tasks/new";
      },
      's': function() {
        location.href = "/users/"+ VIEWER_ID +"/subscribed?status=prioritized";
      },
      'y': function() {
        location.href = "/";
      },
      '¿': function() {
        $("#q").focus();
      }
    });
    // TODO: MOve this over to shortkeys when it supports the concept of a
    // "universal" shortcut, a shortcut that works regardless of whether you're
    // on a form field or not.
    $(window).keydown(function(event) {
      if (user.keyboard.character() == "esc") {
        event.preventDefault();
        $("#task_title").blur();
        $(".quick_cancel_link:eq(0)").trigger("click");
      }
    });
  }
};

var FlashMessage = {
  hideAfterDelay: function () {
    setTimeout(function (el) {
      $('#flash_container').slideUp();
    }, 5000);
  }
};

var Navigation = {
  onShow: function(elem) {
    $(this).prev().toggleClass("hover");
  },
  onHide: function() {
    $(this).prev().toggleClass("hover");
  }
};

$(function() {
  $('ul.sf-menu').superfish({
    delay:  0,
    speed:  'fast'
  });

  $("#filters > li").hover(function() {
    $(this).find(">a").toggleClass("hover");
  }, function() {
    $(this).find(">a").toggleClass("hover");
  });

  $("textarea").keydown(function(event) {
    if (user.keyboard.character() == "enter") {
      $(this).height($(this).height() + 20);
    }
  });
  $("#q").hint();
  KeyboardShortcuts.setup();
  FlashMessage.hideAfterDelay();
});
