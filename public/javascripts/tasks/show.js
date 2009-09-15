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

function focusChangeComment(parentId) {
  $(parentId + " #change_comment_text").val($("#comment_text").val());
  $(parentId + " #change_comment_text").focus();
}

$(function(){
  $("#complete_link").click(function(e) {
    e.preventDefault();
    $("#confirm_completion").modal();
    focusChangeComment("#confirm_completion");
  });
  var linkIds = ["mark_incomplete_link", "prioritize_link", "park_link"];
  for (var i = 0; i < linkIds.length; i++) {
    $("#" + linkIds[i]).click(function(e) {
      var id = $(this).attr("id");
      e.preventDefault();
      $("#change_task_header").
        text(TASK_ACTION_INFO[id].header);
      $("#change_task_submit_name").
        attr("value", TASK_ACTION_INFO[id].submitText);
      $("#change_comment_form").attr("action", TASK_ACTION_INFO[id].url);
      $("#change_task_dialog").modal();
      focusChangeComment("#change_task_dialog");
    });    
  }
  $("#task_primary_info h1").inlineEditor();
  $("#task_logistics li").inlineEditor();
  $("#description").inlineEditor({onSuccessFn: function(elem) {
    elem.find(".editable").removeClass("empty");
  }});
  $("#status_container").inlineEditor();
  TaskShortkeys.setup();
})
