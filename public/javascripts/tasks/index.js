var Tasks = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.task_list tbody > tr',
      update: function (evt, ui) {
      $.post("/tasks/reorder", {
        list_item_id: ui.item.attr('id').replace(/list_item_/, ''),
        list_item_position: ui.item.prevAll().length + 1
      },
      function (data) {}, "json");
      }
    });
  }
};
$(document).ready(function() {
  Tasks.makeSortable();
});