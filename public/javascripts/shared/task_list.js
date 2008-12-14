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
  }
};
$(function() {
  Tasks.makeSortable();
  Tasks.setupQuickAdd();
});
