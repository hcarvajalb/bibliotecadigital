$(document).ready(function(){
        
    
    
$(function(){
        $(".desc").each(function(i){
          len=$(this).text().length;
          if(len>10)
          {
            $(this).text($(this).text().substr(0,280)+'...');
          }
        });       
      });

      $(function () {
        $('[data-toggle="tooltip"]').tooltip()
      });
      


if (!String.prototype.replaceLast) {
    String.prototype.replaceLast = function(find, replace) {
        var index = this.lastIndexOf(find);

        if (index >= 0) {
            return this.substring(0, index) + replace + this.substring(index + find.length);
        }

        return this.toString();
    };
}
      
$( "#aspect_discovery_Navigation_list_discovery .list-group-item a" ).each(function() {
value = $(this).text();
value=value.replaceLast("(", "<span class=\"badge pull-right\">").replaceLast(")","</span>");
$(this).html(value);
});


$('[id^="aspect_discovery_SearchFacetFilter_div_browse-by-"][id$="-results"] td a').each(function() {
value = $(this).text();
value=value.replaceLast("(", "<span class=\"badge pull-right\">").replaceLast(")","</span>");
$(this).html(value);
});


$('[id^="aspect_artifactbrowser_ConfigurableBrowse_div_browse-by-"][id$="-results"] td').each(function() {
value = $(this).html();
value=value.replaceLast("[", "<span class=\"badge pull-right\">").replaceLast("]","</span>");
$(this).html(value);
});

});
