$(function() {
  // TODO: Make the url construction work for multiple filters.
  $(".task_filter").change(function() {
    name = $(this).attr("name");
    val = $(this).val();
    location.href = location.pathname + "?" + name + "=" + val
  })
})
