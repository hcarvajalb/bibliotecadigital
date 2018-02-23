
  $('[data-toggle="offcanvas"]').click(function () {
    $('.row-offcanvas').toggleClass('active')
  });


  $('#container-floating').click(function() {
    $('').toggle();
    $("i", this).toggleClass("fa fa-indent fa fa-close");
});