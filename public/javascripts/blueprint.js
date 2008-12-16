$(document).ready(function() {
  $('ul.sf-menu').superfish({
    delay:      0,
    speed:      'fast'
  });
  $("textarea").keydown(function(event) {
    if (user.keyboard.character() == "enter") {
      $(this).height($(this).height() + 22);
    }
  });
})

