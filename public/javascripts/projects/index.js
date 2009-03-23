var Projects = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.project_list:not(.unsortable) tbody > tr',
      update: function (evt, ui) {
        $.post("/project_list_items/reorder", {
          id: ui.item.attr('id').replace(/list_item_/, ''),
          position: ui.item.prevAll().length + 1
        }, function (data) {}, "json");
      }
    });
  },
  setupInlineEditing: function() {
    $(".phase").inlineEditor();
  }
}

$(function() {
  Projects.makeSortable();
  Projects.setupInlineEditing();
})
