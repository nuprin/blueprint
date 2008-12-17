var Tasks = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.task_list:not(.unsortable) tbody>tr',
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
  setupTypeaheads: function() {
    $(".quick_add_form").each(function(i, form) {
      var f = form;
      $("#task_title", f).autocompleteArray(AUTOCOMPLETE_DATA[0], {
        onItemSelect: function(e) {
          projectTitle = e.innerHTML;
          i = $.inArray(projectTitle, AUTOCOMPLETE_DATA[0]);
          formFieldId = "task_" + AUTOCOMPLETE_DATA[1][i];
          projectId = AUTOCOMPLETE_DATA[2][i];
          $("#" + formFieldId, f).val(projectId);
          $("#task_title", f).val("");
          $("<li id='quick_add_" + formFieldId + "'>" +
            projectTitle + "</li>").appendTo($(".quick_add_items", f));
          $("#quick_add_" + formFieldId, f).click(function() {
            field = $(this).remove().attr('id').replace(/quick_add_/, '');
            $("#" + field, f).val("");
            $("#task_title", f).focus();
          });
          $("#task_title", f).focus();
        }
      });
      $(this).submit(function(e) {
        e.preventDefault();
        $(this).ajaxSubmit(function(data){
          var table = $(e.target).parents("table.task_list")
          if ($("#task_status", table).val() == "parked") {
            $(data).prependTo($("tbody", table));            
          } else {
            $(data).appendTo($("tbody", table));
          }
          $("#task_title", table).focus().select();
        });
      })
    })
  }
};

$(function() {
  Tasks.makeSortable();
  Tasks.setupQuickAdd();
  Tasks.setupActions();
  Tasks.setupTypeaheads();
});
