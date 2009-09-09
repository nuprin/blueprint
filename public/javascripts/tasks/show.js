var TaskShortkeys = {
  edit: function() {
    location.href += "/edit"
  },
  parkOrPrioritize: function() {
    $(".task_park_link").click();
    $(".task_prioritize_link").click();
  },
  complete: function() {
    $("#complete_link").click();
  },
  deleteTask: function() {
    $(".task_delete_link").click();
  },
  setup: function() {
    $(document.body).shortkeys({
      'e':       TaskShortkeys.edit,
      'p':       TaskShortkeys.parkOrPrioritize,
      'x':       TaskShortkeys.complete,
      'Shift+1': TaskShortkeys.deleteTask,
    }, {moreKeys: {
      'Shift': 16,
    }});
  }
}

$(function(){
  $("#complete_link").click(function(e) {
    e.preventDefault();
    // $("#confirm_completion").show().animate({top: 100});
    // $(".simplemodal-close").click(function(e) {
    //   e.preventDefault();
    //   $("#confirm_completion").animate({top: -200});
    // });
    $("#confirm_completion").modal();
    $("#final_comment_text").val($("#comment_text").val());
    $("#final_comment_text").focus();
  })
  $("#task_primary_info h1").inlineEditor();
  $("#task_logistics li").inlineEditor();
  $("#description").inlineEditor({onSuccessFn: function(elem) {
    elem.find(".editable").removeClass("empty");
  }});
  $("#status_container").inlineEditor();
  TaskShortkeys.setup();
})
