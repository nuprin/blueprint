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
    return this.each(function() {  
      var inputField;
      var settings = $.extend({}, $.fn.inlineEditor.defaults, options);
      var editElement;

      var setup = function() {
        adjustWidths();
        form.find("input").blur(onBlur);
        form.find("select").blur(onBlur);
        form.find("textarea").blur(onBlur);
        form.submit(onChange);
        setupCancel();

        if (editable.html() && editable.html().length > 0)
          form.hide();
        editable.attr("title", settings.title);


        // Double-click Mode: Double-click to trigger, remove focus to hide.
        if (settings.doubleClickMode) {
          clickable.dblclick(displayForm);
        // Edit Mode: Click edit to trigger, explicitliy click cancel to hide.
        } else {
          setupEditLink();
        }
      }

      var setupEditLink = function() {
        editElement = $("<span>edit</span>");
        editElement.hide();
        editElement.attr("class", "edit_link");
        clickable.css({position: "relative"});
        clickable.mouseover(function() {
          if (clickable.hasClass("editing")) {
            editElement.hide();
          } else {
            editElement.show();
          }
        });
        clickable.mouseout(function() {
          editElement.hide();          
        });
        clickable.append(editElement);
        editElement.click(displayForm);
      }

      var onSuccess = function(data) {
        form.hide();
        editable.show();
        editable.html(data);
        editable.removeClass(settings.errorClass);
        clickable.removeClass("editing");
        $(document.body).sortable('enable');
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

      var onChange = function(e) {
        if (settings.useAjax) {
          e.preventDefault();
          form.ajaxSubmit({success: onSuccess, error: onError});
        }
        else {
          form.submit();
        }
      }
      
      var displayForm = function(e) {
        if (e.target.tagName == "A") {
          return;
        }
        editable.hide();
        form.show();
        processInput();
        processSelect();
        processTextArea();
        $(".edit_link").hide();
        clickable.addClass("editing");
        $(document.body).sortable('disable');
      }

      var onBlur = function(e) {
        if (form.find("input[type=submit]").length == 0) {
          onCancel();
        }
      }

      var onCancel = function() {
        form.hide();
        editable.show();
        clickable.removeClass("editing");
        $(document.body).sortable('enable');
      }

      var adjustWidths = function() {
        textInput.width(clickable.width() - 10);
        select.width(clickable.width());
        textarea.width(clickable.width());        
      }

      var processInput = function() {
        if (textInput.length > 0) {
          inputField = textInput;
          textInput.focus().select();            
        }
      }

      var processSelect = function() {
        if (select.length > 0) {
          inputField = select;
          select.focus();
          if (settings.submitFormOnChange) {
            select.change(onChange);
          }
        }
      }

      var processTextArea = function() {
        if (textarea.length > 0) {
          inputField = textarea;
          inputField.focus();
        }
      }

      var setupCancel = function() {
        form.find(".inlineCancel").each(function() {
          $(this).click(onCancel);
        })
      }

      var clickable = $(this);
      var form = clickable.find("form");
      var select = form.find("select");
      var textInput = form.find("input[type=text]");
      var textarea = form.find("textarea");
      var editable = clickable.find(".editable");
      setup();
    });
  };
})(jQuery);

$.fn.inlineEditor.defaults = {
  errorClass: "inlineError",
  useAjax: true,
  submitFormOnChange: true,
  doubleClickMode: true
};
