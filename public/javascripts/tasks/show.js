$(function(){
  $("#complete_link").click(function(e) {
    e.preventDefault();
    $("#confirm_completion").modal();
    $("#final_comment_text").val($("#comment_text").val());
    $("#final_comment_text").focus();
  })
  $("#task_primary_info h1").inlineEditor();
  $("#description").inlineEditor({onSuccessFn: function(elem) {
    elem.find(".editable").removeClass("empty");
  }});
  $("#status_container").inlineEditor();
})
