<?php 
require 'autoload.php';
include 'Configs.php';

use Parse\ParseObject;
use Parse\ParseQuery;
use Parse\ParseACL;
use Parse\ParsePush;
use Parse\ParseUser;
use Parse\ParseInstallation;
use Parse\ParseException;
use Parse\ParseAnalytics;
use Parse\ParseFile;
use Parse\ParseCloud;
use Parse\ParseClient;
use Parse\ParseSessionStorage;
session_start();

	if ($_FILES["file"]["error"] > 0) {
 		echo "Error: " . $_FILES["file"]["error"] . "<br />";
  	} else {

  	// Crop image to max dimension = 300px
	$maxDim = 600;
    
    $file_name = $_FILES['file']['tmp_name'];
    list($width, $height, $type, $attr) = getimagesize( $file_name );

    if ( $width > $maxDim || $height > $maxDim ) {
        $target_filename = $file_name;
        $ratio = $width/$height;
        if( $ratio > 1) {
            $new_width = $maxDim;
            $new_height = $maxDim/$ratio;
        } else {
        	$new_width = $maxDim*$ratio;
            $new_height = $maxDim;
		}
        
        $src = imagecreatefromstring( file_get_contents( $file_name ) );
        $dst = imagecreatetruecolor( $new_width, $new_height );
        imagecopyresampled( $dst, $src, 0, 0, 0, 0, $new_width, $new_height, $width, $height );
       	imagedestroy( $src );
		imagepng( $dst, $target_filename ); 
		imagedestroy( $dst );
        
        uploadImage();

    } else { uploadImage(); }
}
		
// UPLOAD IMAGE ------------------------------------------
function uploadImage() {
    // generate a unique random string
    $randomStr = generateRandomString();
    // upload image into the 'uploads' folder
    move_uploaded_file($_FILES["file"]["tmp_name"], "uploads/".$randomStr.".jpg");

    // echo the link of the uploaded image
    echo "uploads/" .$randomStr.".jpg";
}


// GENERATE A RANDOM STRING ---------------------------------------
function generateRandomString($length = 15) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}
?>