var Spec = {
  save: function() {
    $("#spec_form").ajaxSubmit();
    $("#saved_msg").text("Automatically saved at " +
      new Date().toLocaleTimeString() + ".");
  }
}

$(function() {
  $("#spec_body").wysiwyg({
    controls: {
      insertOrderedList:    {visible: true},
      insertUnorderedList:  {visible: true},
      h1mozilla:            {visible: false},
      h1:                   {visible: false},
      insertHorizontalRule: {visible: true},
      indent:               {visible: true},
      outdent:              {visible: true}
    },
    css: "/stylesheets/projects/spec/body.css"
  });
  // setInterval(Spec.save, 5000)
});
