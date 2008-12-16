$(function() {
  $("#project_description").wysiwyg({
    controls: {
      insertOrderedList:   {visible: true},
      insertUnorderedList: {visible: true},
      css: "projects/spec.css"
    }
  });
  setInterval(function() {
    $("#saving").attr("style", "visibility: visible");
    $("#spec_form").ajaxSubmit(function() {
      $("#saving").attr("style", "visibility: hidden");
    });
  }, 2000)
})
