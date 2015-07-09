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

handle_image_load = function() {
    $("#image").load(function() {
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
    }); 
}

replace_image = function(new_src) {
    $("#image_preview").html($("<img>", {
        id: "image", 
        class: "img-responsive center-block",
        alt: "Enter an image URL to begin cropping!",
        src: new_src
    }));
    //prepare a cropper frame on top of the image when it loads
    handle_image_load();
}

function read_url(input) {
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

$(document).ready(function (){
    //lay out initial cropper on top of the image loaded by default
    handle_image_load();

    //bind logic into image upload button
    $("#widgets_image_image_upload").change(function(){
        read_url(this);
    });

    //loads the image into image preview when image_url is changed:
    $("#widgets_image_image_url").change(function() {
        //append new image to image preview
        replace_image($("#widgets_image_image_url").val()+'?'+new Date().getTime())
    });
})
