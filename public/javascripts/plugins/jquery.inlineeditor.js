/* 
 * An inline editor plugin for jQuery.
 * By Chris Chan <chris@causes.com>
 * 
 */

/*
 * TODO: 
 *   1. Figure out how to store state for every inline editor.
 *   2. How to streamline interface to require a minimum of markup.
 */
;(function($) {
  $.fn.inlineEditor = function(options) {
    var settings = $.extend($.fn.inlineEditor.defaults, options);

    return this.each(function() {  
      var inputField;

      var onSuccess = function(data) {
        form.hide();
        editable.show();
        editable.html(data);
        editable.removeClass(settings.errorClass);
        clickable.removeClass("editing");
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
        if (settings.useAjax) {
          e.preventDefault();
          form.ajaxSubmit({success: onSuccess, error: onError});
        }
      }

      var onChange = function(e) {
        if (settings.useAjax) {
          e.preventDefault();
          form.ajaxSubmit({success: onSuccess, error: onError});
        }
        else {
          form.submit();
        }
      }

      var onClick = function(e) {
        if (e.target.tagName == "A") {
          return;
        }
        editable.hide();
        form.css("display", "inline");
        processInput();
        processSelect();
        processTextArea();
        inputField.blur(onBlur);
        clickable.addClass("editing");
      }

      var onBlur = function(e) {
        if (form.find("input[type=submit]").length == 0) {
          form.hide();
          editable.show();
          clickable.removeClass("editing");
        }
      }

      var processInput = function() {
        if (textInput.length > 0) {
          inputField = textInput;
          textInput.focus().select();
          form.submit(onSubmit);        
        }
      }

      var processSelect = function() {
        if (select.length > 0) {
          inputField = select;
          select.focus();
          select.change(onChange);
        }
      }

      var processTextArea = function() {
        if (textarea.length > 0) {
          inputField = textarea;
          inputField.focus();
          form.submit(onSubmit);
        }
      }

      var clickable = $(this);
      var form = clickable.find("form");
      var select = form.find("select");
      var textInput = form.find("input[type=text]");
      var textarea = form.find("textarea");
      var editable = clickable.find(".editable");
      
      var styles = ["font-size", "font-weight"];
      for (var i in styles) {
        textInput.css(styles[i], clickable.css(styles[i]));
      }
      
      if (editable.html() && editable.html().length > 0)
        form.hide();
      editable.attr("title", settings.title);
      clickable.click(onClick);
    });
  };
})(jQuery);

$.fn.inlineEditor.defaults = {
  errorClass: "inlineError",
  title: "Click to Edit",
  useAjax: true
};
