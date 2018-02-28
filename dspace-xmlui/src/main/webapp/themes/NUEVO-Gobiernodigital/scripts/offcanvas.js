
  $('[data-toggle="offcanvas"]').click(function () {
    $('.row-offcanvas').toggleClass('active');
    $('footer').toggleClass('footermargin')
  });


  $('#container-floating').click(function() {
    $('').toggle();
    $("i", this).toggleClass("fa fa-indent fa fa-close");
});