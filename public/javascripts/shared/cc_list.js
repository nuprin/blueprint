var CCList = {

  setup: function() {
    this.setupTypeaheads();
    this.setupDestruction();
  },
  submitter: function(f) {
    $(f).ajaxSubmit(function(data){
      $(data).prependTo($('ul#cc_list')).hide().fadeIn("fast").
        click(function() {
          CCList.destructionHandler(this)
        });
    });
    $(f).find('input.ac_input').val('').focus();
  },
  destructionHandler: function(elem) {
    var id = elem.id.split('_')[1];
    $('#cc_deletion_form').each(function() {
      //todo[kball] : clean this up
      var tmp = this.action.split('/');
      var id_size = tmp[tmp.length - 1].length
      this.action = this.action.slice(0,-1 * id_size) + id;
      $(this).ajaxSubmit()
    });
    $(elem).fadeOut("fast").remove();
  },
  setupTypeaheads: function() {
    $("#cc_form").each(function() {
      var f = this;
      $("#task_subscription_user_name", f).
        autocompleteArray(AUTOCOMPLETE_DATA[0], {
          onItemSelect: function(e) {
            var name = e.innerHTML;
            i = $.inArray(name, AUTOCOMPLETE_DATA[0])
            var type = AUTOCOMPLETE_DATA[1][i];
          //hack to deal with autocomplete containing all.  Maybe should slice it
            if(type == 'kind')
              alert("Can't CC a kind");
            else if (type == 'project_id')
              alert("Can't CC a project");
            else {
              CCList.submitter(f);
            }
          }
      });
      $(this).submit(function(e) {
        e.preventDefault();
        CCList.submitter(this);
      });
    });
  },
  setupDestruction: function() {
    $('#cc_list').find('li').click(function() {
      CCList.destructionHandler(this);
    });
  }
}
$(function() {
  CCList.setup();
});
