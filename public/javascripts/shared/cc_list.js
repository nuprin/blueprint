var CCList = {
  setup: function() {
    this.setupDropDown();
  },
  setupDropDown: function() {
    $("#cc_form").find("select").change(function() {
      CCList.submitter($(this));
    })
  },
  submitter: function(selectElem) {
    $('#cc_form').ajaxSubmit(function(data){
      $(data).appendTo($('#cc_list'));
      selectElem.children().each(function(i, elem) {
        if (elem.value == selectElem.val()) {
          $(elem).remove();
        }
      })
      if (selectElem.children().length == 1) {
        selectElem.remove();
      }
    });
  }
}

$(function() {
  CCList.setup();
});
