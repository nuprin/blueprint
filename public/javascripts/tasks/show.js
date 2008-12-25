$(function(){
  $("#task_description").focus(function(){
    $(this).parents("form").addClass("editing");
  })
  $("#complete_link").click(function(e) {
    console.log("HELLO")
    e.preventDefault();
    $("#confirm_completion").modal({overlayCss: {
        backgroundColor: '#000'
      },
      containerCss: {
        width: '400px',
        backgroundColor: '#fff',
        border: '3px solid #ccc',
        padding: '20px 15px'
      }
    });
    $("#final_comment_text").focus();
  })
})
