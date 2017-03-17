$(() => {
  const $banner = $('.cover-photo');
  const width = $(window).width();
  const mobile_breakpoint = 480;
  const data = $banner.data();
  const tempImage = new Image();

  tempImage.onload = () => {
    $banner.css('backgroundImage', `url("${tempImage.src}")`);
    $banner.addClass('visible');
  };

  if (width <= mobile_breakpoint) {
    tempImage.src = data.mobileImage;
  } else {
    tempImage.src = data.desktopImage;
  }
});
