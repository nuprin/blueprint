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
        textInput.val(data);
        editable.text(textInput.val());
        editable.removeClass(settings.errorClass);
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

      var onClick = function() {
        editable.hide();
        form.show();
        textInput.focus().select();
        form.submit(onSubmit);
      }

      var form = $(this);
      var textInput = form.find("input[type=text]");
      var editable = $("<div>" + textInput.val() + "</div>").insertAfter(form);

      form.hide();
      editable.attr("title", settings.title);
      editable.attr("class", "editable");
      editable.click(onClick);    
    });
  };
})(jQuery);

$.fn.inlineEditor.defaults = {
  errorClass: "inlineError",
  title: "Click to edit"
};
