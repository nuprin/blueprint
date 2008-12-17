var Spec = {
  replaceMockrLinks: function() {
    $("a[href^=http://mockr]").each(function(i, elem){
      var src =
        $(elem).attr("href").replace("http://mockr:9300", 
                                  "http://mockr:9300/images/mocks/");
      $(elem).html($("<img src='" + src + "' width='100' />"));
    })  
  },
  addEditLinks: function() {
    $("h1,h2,h3", "#spec").
      append("<a class='edit_links' href='" + EDIT_SPEC_PATH + "'>(Edit)</a>");    
  },
  makeBlankLinks: function() {
    $("a[class!=edit_links]", "#spec").attr("target", "_blank");    
  }
}
$(function(){
  Spec.addEditLinks();
  Spec.replaceMockrLinks();
  Spec.makeBlankLinks();
})
