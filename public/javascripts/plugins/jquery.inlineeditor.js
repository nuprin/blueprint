/* An inline editor plugin for jQuery. */
jQuery.fn.inlineEditor = function(options) {
  var settings = jQuery.extend({errorClass: "inlineError"}, options);

  this.each(function() {  
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
    editable.attr("title", "Click to edit");
    editable.click(onClick);    
  });
}
