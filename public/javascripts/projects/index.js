var Projects = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.project_list:not(.unsortable) tbody > tr',
      update: function (evt, ui) {
        $.post("/project_list_items/reorder", {
          id: ui.item.attr('id').replace(/list_item_/, ''),
          position: ui.item.prevAll().length + 1
        }, function (data) {
          $("table.project_list tr").each(function(i) {
            $(this).find(".position").text(i + 1);
          });
          console.log("Done!");
        }, "json");
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
