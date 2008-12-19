var Tasks = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.task_list:not(.unsortable) tbody>tr',
      update: function (evt, ui) {
        context = ui.item.attr('class').split('_');
        $.post("/tasks/reorder", {
          list_item_id: ui.item.attr('id').replace(/list_item_/, ''),
          list_item_position: ui.item.prevAll().length + 1
        },
        function (data) {}, "json");
      }
    });
  },
  setupActions: function(trElem) {
    trElem = trElem || $("table.task_list tr")
    trElem.hover(function(){
      $(this).find(".task_links").fadeIn(50);
    }, function(){
      $(this).find(".task_links").fadeOut(50);
    });
  }
};

var QuickAdd = {
  open: function() {
    $(this).parents("tfoot").addClass('editing');
    $(this).prev().children("input[type=text]").focus().select();
  },
  close: function() {
    $(this).parents("tfoot").removeClass('editing');    
  },
  setup: function() {
    $("a.quick_add_link").click(this.open);
    $("a.quick_cancel_link").click(this.close);
    this.setupTypeaheads();
  },
  setupTypeaheads: function() {
    $(".quick_add_form").each(function(i, form) {
      var f = form;
      $("#task_title", f).autocompleteArray(AUTOCOMPLETE_DATA[0], {
        selectFirst: true,
        onItemSelect: function(e) {
          projectTitle = e.innerHTML;
          i = $.inArray(projectTitle, AUTOCOMPLETE_DATA[0]);
          formFieldId = "task_" + AUTOCOMPLETE_DATA[1][i];
          projectId = AUTOCOMPLETE_DATA[2][i];
          $("#" + formFieldId, f).val(projectId);
          $("#task_title", f).val("");
          $("<li id='quick_add_" + formFieldId + "'>" +
            projectTitle + "</li>").appendTo($(".quick_add_items", f));
          $("#quick_add_" + formFieldId, f).click(function() {
            field = $(this).remove().attr('id').replace(/quick_add_/, '');
            $("#" + field, f).val("");
            $("#task_title", f).focus();
          });
          $("#task_title", f).focus();
        }
      });
      $(this).submit(function(e) {
        e.preventDefault();
        $(this).ajaxSubmit(function(data){
          var table = $(e.target).parents("table.task_list")
          var trElem = $(data);
          Tasks.setupActions(trElem);
          if ($("#task_status", table).val() == "parked") {
            trElem.prependTo($("tbody", table)).hide().fadeIn("fast");            
          } else {
            trElem.appendTo($("tbody", table)).hide().fadeIn("fast");
          }
          $("#task_title", table).focus().select();
        });
      })
    })
  }
}

var KeyboardShortcuts = {
  setupFields: function() {
    $('input[type=text],textarea').focus(function() {
      $(document.body).addClass("typing");
    });
    $('input[type=text],textarea').blur(function() {
      $(document.body).removeClass("typing");
    });
  },
  setup: function() {
    this.setupFields();
    $(window).keydown(function(event) {
      if (!$(document.body).hasClass("typing")) {
        if (user.keyboard.character() == "A") {
          event.preventDefault();
          $(".quick_add_link:eq(0)").trigger("click");
        }
      }
      if (user.keyboard.character() == "esc") {
        event.preventDefault();
        $("#task_title").blur();
        $(".quick_cancel_link:eq(0)").trigger("click")
      }
    })
  }
}

$(function() {
  Tasks.makeSortable();
  Tasks.setupActions();
  QuickAdd.setup();
  KeyboardShortcuts.setup();
});

