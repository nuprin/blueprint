var Tasks = {
  makeSortable: function() {
    $(document.body).sortable({
      axis:  'y',
      items: 'table.task_list:not(.unsortable) tbody > tr',
      update: function (evt, ui) {
        $.post("/tasks/reorder", {
          list_item_id: ui.item.attr('id').replace(/list_item_/, ''),
          list_item_position: ui.item.prevAll().length + 1
        }, function (data) {}, "json");
      },
      // These extra fields seem to jump when dragging a table. Hide them for
      // now.
      start: function(evt, ui) {
        ui.helper.find(".menu_arrow").hide();
        ui.helper.find(".editable").hide();
      }
    });
  },
  setupActions: function(trElem) {
    trElem = trElem || $("table.task_list tr")
    var currentMenuContainer;
    $("#content").click(function(e) {
      if (currentMenuContainer &&
          $(e.target).parents(".task_menu_container").length == 0) {
        currentMenuContainer.removeClass("active");
      }
    });
    trElem.find(".task_menu_container").click(function() {
      if (currentMenuContainer) {
        currentMenuContainer.removeClass("active");
      }
      $(this).addClass("active");
      currentMenuContainer = $(this);
    });
  },
  setupInlineEditing: function(trElem) {
    estimateForms = trElem ? trElem.find(".task_estimate>.inline_form") :
                             $(".task_estimate>.inline_form");
    dueDateForms = trElem ? trElem.find(".task_due>.inline_form") :
                            $(".task_due>.inline_form");
    estimateForms.inlineEditor({
      title: "Click to edit estimate",
      onSuccessFn: function(form) {
        form.parents("td").removeClass("empty");
      }
    });
    dueDateForms.inlineEditor({title: "Click to edit due date"});
    assigneeCells = trElem ? trElem.find(".task_assignee") : $(".task_assignee")
    assigneeCells.click(function(e) {
      if (e.target.tagName != "A")
        $(this).addClass("editing");
    })
  },
  updateType: function(linkElem) {
    var form = linkElem.parent();
    var trElem = linkElem.parents("tr.task");
    form.ajaxSubmit({
      success: function(data) {
        var newTrElem = $(data);
        Tasks.setupActions(newTrElem);
        Tasks.setupInlineEditing(newTrElem);
        trElem.replaceWith(newTrElem);
      }
    })
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
        delay: 100,
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
          Tasks.setupInlineEditing(trElem);
          if ($("#task_status", table).val() == "parked") {
            trElem.prependTo($("tbody", table)).hide().fadeIn("fast");            
          } else {
            trElem.appendTo($("tbody", table)).hide().fadeIn("fast");
          }
          $("#task_title", table).val("").focus();
        });
      })
    })
  }
}

var Fluid = {
  setup: function() {
    if (window.fluid) {
      if (PRIORITIZED_TASK_COUNT)
        window.fluid.dockBadge = PRIORITIZED_TASK_COUNT;
    }
  }
}

$(function() {
  Tasks.makeSortable();
  Tasks.setupActions();
  Tasks.setupInlineEditing();
  QuickAdd.setup();
  Fluid.setup();
});
