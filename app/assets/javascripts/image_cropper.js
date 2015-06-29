// Creates a function that returns parameters built based on DOM image element size
// that get passed to cropper.js for the image crop UI when creating petitions or donations.
create_cropper_parameters = function(ratio_width, ratio_height, image_id) {
    var dom_image = document.getElementById(image_id);
    //Since we want a fixed ratio. Setting max_width and height on top of the ratio is necessary
    //because we are using responsive images.
    var cropper_parameters = {
        ratio: {
            width: ratio_width,
            height: ratio_height
        },
        max_height: 0,
        max_width: 0,
    }        
    // Setting max dimensions for the image cropping box. 
    // If image is wider than it is tall, use its height to constrain crop size.
    // else, use its width. Without these, it fails on responsive images.
    if (dom_image.offsetHeight <= dom_image.offsetWidth) {
        cropper_parameters.max_height = dom_image.offsetHeight;
        cropper_parameters.max_width = cropper_parameters.max_height/ratio_height*ratio_width;
    }
    else {
        cropper_parameters.max_width = dom_image.offsetWidth;
        cropper_parameters.max_height = cropper_parameters.max_width/ratio_width*ratio_height;
    }
    return cropper_parameters;
}

replace_image = function(new_src) {
    $("#image_preview").html($("<img>", {
        id: "image", 
        class: "img-responsive center-block",
        alt: "Enter an image URL to begin cropping!",
        src: new_src
    }));
    handle_image_load();
}

handle_image_load = function() {
    $("#image").on('load', function() {
        // the image ratio is 14x10
        image_cropper_parameters = create_cropper_parameters(14, 10, 'image');
        image_cropper_parameters.update = function (coordinates) {
            var cropper_width = $(".cropper").width()
            var cropper_height = $(".cropper").height()
            $("#image_x").val(coordinates['x']/cropper_width)
            $("#image_y").val(coordinates['y']/cropper_height)
            $("#image_width").val(coordinates['width']/cropper_width)
            $("#image_height").val(coordinates['height']/cropper_height)

        }
        //Load new cropper frame on top of the new image
        new Cropper($(this).get(0), image_cropper_parameters);
    })
}

attach_image_handlers = function() {
    //get file data when the user uploads an image with the upload button
    $('#widgets_image_image_upload').change(function(){
        read_url(this);
    });

    //loads the image into image preview when image_url is changed:
    $('#widgets_image_image_url').change(function() {
        //append new image with src from the url to image preview (date is appended to deal with caching)
        replace_image($('#widgets_image_image_url').val()+'?'+new Date().getTime())
    });
}

read_url = function(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = (function(theFile) {
            return function(e) {
                replace_image(e.target.result)
            }
        })(input.files[0])
        // read the image file as a data URL
        reader.readAsDataURL(input.files[0]);
    }
}

// attaches handlers after ajax request for changing template changes
$(document).ajaxComplete(function(){
    handle_image_load();
    attach_image_handlers();
})

//attaches handlers for loading the initial/default template
$('#image_widget_form').ready(function (){
    handle_image_load();
    attach_image_handlers();

})
