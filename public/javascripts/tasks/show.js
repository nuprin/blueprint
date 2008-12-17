$(function(){
  $("#task_description").focus(function(){
    $(this).parents("form").addClass("editing");
  })
})