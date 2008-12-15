var Tasks = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.task_list tbody>tr',
      update: function (evt, ui) {
        context = ui.item.attr('class').split('_');
        $.post("/tasks/reorder", {
          list_item_id: ui.item.attr('id').replace(/list_item_/, ''),
          list_item_position: ui.item.prevAll().length + 1
        },
        function (data) {
        
        }, "json");
      }
    });
  },
  setupQuickAdd: function() {
    $("a.quick_add_link").click(function() {
      $(this).parents("tfoot:eq(0)").addClass('editing');
      $(this).prev().children("input[type=text]").focus();
    });
    $("a.quick_cancel_link").click(function() {
      $(this).parents("tfoot:eq(0)").removeClass('editing');
    });
  },
  setupActions: function() {
    $("table.task_list tr").hover(function(){
      $(this).find(".task_links").fadeIn(50);
    }, function(){
      $(this).find(".task_links").fadeOut(50);
    });
  },
  // TODO: This assumes one typeahead per page when there can be two or more.
  setupTypeahead: function() {
    $("#task_title").autocompleteArray(PROJECTS[0], {
      onItemSelect: function(e) {
        projectTitle = e.innerHTML;
        i = jQuery.inArray(projectTitle, PROJECTS[0]);
        projectId = PROJECTS[1][i];
        $("#task_project_id").val(projectId);
        $("#task_title").removeAttr("value");
        $(".quick_add_project").text(projectTitle).show();
        $("#task_title").focus();
      }
    });
    $(".quick_add_project").click(function() {
      $("#task_project_id").removeAttr("value");
      $(".quick_add_project").hide();
      $("#task_title").focus();
    })
  }
};

$(function() {
  Tasks.makeSortable();
  Tasks.setupQuickAdd();
  Tasks.setupActions();
  Tasks.setupTypeahead();
});
