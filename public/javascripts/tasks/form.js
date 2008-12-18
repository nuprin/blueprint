$(function() {
  $("#use_due_date").change(function() {
    // console.log($(this).selected())
    if ($(this).attr("checked") == true) {
      $("[id^=task_due_date_]").show()
    } else {
      $("[id^=task_due_date_]").hide()    
    }
  })
})
