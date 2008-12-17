$(function(){
  $("a", "#spec").attr("target", "_blank");
  $("h3", "#spec").append("<a href='" + EDIT_SPEC_PATH + "'>(Edit)</a>");
})