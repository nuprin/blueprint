var Tasks = {
  makeSortable: function (id) {
    $('#' + id).sortable({
      axis: 'y',
      items: 'tbody > tr',
      update: function (evt, ui) {
        $.post("/tasks/reorder", {
          list_item_id: ui.item.attr('id').replace(/list_item_/, ''),
          list_item_position: ui.item.prevAll().length + 1
        },
        function (data) {
          // don't do anything after the update is complete
          //$("#output").text("updated "+ ui.item.attr('id'));
        }, "json");
      }
    });
  }
};
