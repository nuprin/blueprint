$(function(){
  $("#task_description").focus(function(){
    $(this).parents("form").addClass("editing");
  })
  $("#complete_link").click(function(e) {
    e.preventDefault();
    $("#confirm_completion").modal({overlayCss: {
        backgroundColor: '#000'
      },
      containerCss: {
        width: '500px',
        backgroundColor: '#dedfe5',
        border: '3px double #999',
        padding: '20px 15px'
      }
    });
    $("#final_comment_text").val($("#comment_text").val());
    $("#final_comment_text").focus();
  })
  $("#task_primary_info h1").inlineEditor();
  $("#description").inlineEditor();
  $("#status_container").inlineEditor({useAjax: false});
})
