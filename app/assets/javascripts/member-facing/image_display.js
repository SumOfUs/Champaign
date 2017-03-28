$(function() {
  var $banner = $('.cover-photo'),
      width = $(window).width(),
      mobile_breakpoint = 480,
      data = $banner.data(),
      tempImage = new Image();

  tempImage.onload = function() {
    $banner.css('backgroundImage', "url('" + tempImage.src + "')");
    $banner.addClass('visible');
  };

  if (width <= mobile_breakpoint) {
    tempImage.src = data.mobileImage;
  } else {
    tempImage.src = data.desktopImage;
  }
});
