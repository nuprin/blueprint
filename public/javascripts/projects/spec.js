$(function() {
  $("#spec_body").wysiwyg({
    controls: {
      insertOrderedList:   {visible: true},
      insertUnorderedList: {visible: true},
    },
    css: "/stylesheets/projects/spec/body.css"
  });
  setInterval(function() {
    $("#saving").attr("style", "visibility: visible");
    $("#spec_form").ajaxSubmit(function() {
      $("#saving").attr("style", "visibility: hidden");
    });
  }, 2000)
})
