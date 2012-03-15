$(function () {
  $('.table thead th a, .pagination a').live('click', 
    function (e) {
      $.getScript(this.href);
      history.pushState(null, "document.title", this.href);
      e.preventDefault();
    });
  $(window).bind("popstate", function () {
    $.getScript(location.href);
  });
})