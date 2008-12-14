$(document).ready(function() {
  $('ul.sf-menu').superfish({
    delay:      0,
    speed:      'fast'
  });
  $('table.task_list').each(function(i, elem) {
    Tasks.makeSortable(elem);
  });
})