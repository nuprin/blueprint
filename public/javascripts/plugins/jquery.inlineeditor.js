/* 
 * An inline editor plugin for jQuery.
 * By Chris Chan <chris@causes.com>
 * 
 */

;(function($) {
  $.fn.inlineEditor = function(options) {
    var settings = $.extend($.fn.inlineEditor.defaults, options);

    return this.each(function() {  
      var onSuccess = function(data) {
        form.hide();
        editable.show();
        editable.html(data);
        editable.removeClass(settings.errorClass);
        if (settings.onSuccessFn) {
          settings.onSuccessFn(clickable);
        }
      }

      var onError = function() {
        form.hide();
        editable.show();
        editable.text(textInput.val());
        editable.addClass(settings.errorClass);
      }

      var onSubmit = function(e) {
        e.preventDefault();
        form.ajaxSubmit({success: onSuccess, error: onError});
      }

      var onChange = function(e) {
        e.preventDefault();
        form.ajaxSubmit({success: onSuccess, error: onError});
      }

      var onClick = function(e) {
        if (e.target.tagName == "A") {
          return;
        }
        editable.hide();
        form.css("display", "inline");
        if (textInput.length > 0) {
          textInput.focus().select();
          form.submit(onSubmit);
        }
        else if (select.length > 0) {
          select.focus();
          select.change(onChange);
        }
      }

      var clickable = $(this);
      var form = clickable.find("form");
      var select = form.find("select");
      var textInput = form.find("input[type=text]");
      var editable = clickable.find(".editable");

      form.hide();
      editable.attr("title", settings.title);
      clickable.click(onClick);
    });
  };
})(jQuery);

$.fn.inlineEditor.defaults = {
  errorClass: "inlineError",
  title: "Click to Edit"
};
