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
use Parse\ParseGeoPoint;
session_start();

// REQUIRE HTTPS
if ($_SERVER['HTTPS'] != "on") {
    $url = "https://". $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI'];
    header("Location: $url");
    exit;
}
?>
<!-- header -->  
<?php include 'header.php'; ?>

<body class="landing-page ">

<div class="section section-signup page-header" style="background-image: url('assets/img/bg-mobile.jpg');">
    <div class="container">
        <div class="row">
            <div class="col-md-12 ml-auto mr-auto">
              <div class="text-center">
                <img src="assets/img/logo.png" width="100">
                <h3><strong>MyStream</strong></h3>
                <h5>A place for your creativity</h5>
              </div>
              
              <!-- app store badges -->
              <h5 class="text-center">
                <strong>Get the mobile versions here:</strong>
                <br>
                <a href="<?php echo $_GLOBALS['IOS_APPSTORE_LINK'] ?>" target="_blank"><img src="assets/img/appstore-badge.png" width="140"></a>
                  &nbsp; 
                <a href="<?php echo $_GLOBALS['ANDROID_PLAYSTORE_LINK'] ?>" target="_blank"><img src="assets/img/playstore-badge.png" width="140"></a>
              </h5>

            </div>
        </div><!-- /. row -->

    </div><!-- /. container -->
</div><!-- /. section -->



<!-- footer -->
<?php include 'footer.php'; ?>

<script>

// CHECK SCREEN SIZE ------------------------------------
function checkScreenSize(){
    // Get the dimensions of the viewport
    var width = $(window).width();
    var height = $(window).height();

    $('#jqWidth').html(width);
    $('#jqHeight').html(height);

    // Load the mobile page (in case of mobile device)
    if(width > 767){ window.location.href = 'index.php';} 
};
$(document).ready(checkScreenSize);    // When the page first loads
$(window).resize(checkScreenSize);     // When the browser changes size

</script>

</body>
</html>