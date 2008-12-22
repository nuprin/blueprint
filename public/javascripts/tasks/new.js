var CCList = {
  setup: function() {
    this.setupTypeaheads();
    this.setupDestruction();
  },
  add: function(name, id) {
    var elem = '<li>' + name + '<input id="cc_' + id + '" type="hidden"' +
               ' value="' + id + '" name="cc[]"/></li>'    
    $(elem).prependTo($('ul#cc_list')).hide().fadeIn("fast").
      click(function() {
        CCList.remove(this)
      });
    $('#cc_text').val('').focus();
  },
  remove: function(elem) {
    $(elem).fadeOut('fast').remove();
  },
  setupTypeaheads: function() {
    $("#cc_text").
      autocompleteArray(NAME_DATA[0], {
        onItemSelect: function(e) {
          var name = e.innerHTML;
          var i = $.inArray(name, NAME_DATA[0])
          var id = NAME_DATA[1][i];
          CCList.add(name, id);
        }
    });
  },
  setupDestruction: function() {
    $('#cc_list').find('li').click(function() {
      CCList.remove(this);
    });
  }
}

$(document).ready(function() {
  CCList.setup();
  $('#task_title').focus();
})
