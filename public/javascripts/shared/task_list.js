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
    trElem.find(".menu_arrow").click(function() {
      if (currentMenuContainer) {
        currentMenuContainer.removeClass("active");
      }
      $(this).parent().addClass("active");
      currentMenuContainer = $(this).parent();
    });
    trElem.find(".task_menu_items").click(function() {
      $(this).parents(".task_menu_container").removeClass("active");
    });
  },
  setupInlineEditing: function(trElem) {
    estimateForms = trElem ? trElem.find(".task_estimate") : 
                             $(".task_estimate");
    estimateForms.inlineEditor({
      onSuccessFn: function(clickable) {
        clickable.removeClass("empty");
      },
      title: "Double-Click to Edit Estimate"
    });

    dueDateForms = trElem ? trElem.find(".task_due") : $(".task_due");
    dueDateForms.inlineEditor({title: "Double-Click to Edit Due Date"});

    assigneeCells = trElem ? trElem.find(".task_assignee") : $(".task_assignee")
    assigneeCells.inlineEditor({title: "Double-Click to Edit Assignee"});

    names = trElem ? trElem.find(".task_name") : $(".task_name");
    names.inlineEditor({title: "Double-Click to Edit Name"});

    projects = trElem ? trElem.find(".task_project") : $(".task_project");
    projects.inlineEditor({title: "Double-Click to Edit Project"});
    
    $(".project_category").inlineEditor({
      title: "Double-Click to Edit Category"
    });
  },
  makeCollapsible: function() {
    $("h2.collapsed").add("h2.expanded").each(function() {
      $(this).css("cursor", "pointer");
      $(this).click(function(event) {
        if (event.target.tagName == "H2") {
          $(this).toggleClass("collapsed");
          $(this).toggleClass("expanded");
          $(this).next().slideToggle("fast");
        }
      })
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
  },
  setupParkUntil: function() {
    $("#custom_time").focus(function() {
      $("#deferred_task_prioritize_at_custom").attr("checked", "checked");
    })
    $("#deferred_task_prioritize_at_custom").click(function() {
      $("#custom_time").focus();
    })
  },
  parkUntil: function(taskId) {
    $("#deferred_task_task_id").val(taskId);
    $("#deferred_task_dialog").modal();
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
  Tasks.setupParkUntil();
  Tasks.makeCollapsible();
  QuickAdd.setup();
  Fluid.setup();
});
