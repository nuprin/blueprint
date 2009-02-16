$(function() {
  $("#spec_body").wysiwyg({
    controls: {
      insertOrderedList:   {visible: true},
      insertUnorderedList: {visible: true},
    },
    css: "/stylesheets/projects/spec/body.css"
  });
});

window.onbeforeunload = function(e) {
  return "You seem to be in the middle of editing a spec."
};