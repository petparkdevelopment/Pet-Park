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
// session_start();
?>
<?php if ($_SESSION['FBID']): ?>
<?php 

$userID = $_SESSION['FBID'];

ParseUser::logInWithFacebook($userID, $_SESSION['TOKEN']);
     
$currentUser = ParseUser::getCurrentUser();

// Get user data
$fullname = $_SESSION['FULLNAME'];
$email = $_SESSION['EMAIL'];

// Make username out of full name
$nameLowercase = strtolower($fullname);
$arr =  explode(" ", $nameLowercase);
$username = '';
foreach($arr as $w){ $username .= $w; }

$currentUser->set("username", $username);
// $currentUser->set("fullName", $fullname);
if($email == null) {
    $email = $userID.'@facebook.com';
    $currentUser->set("email", $email);
} else {
    $currentUser->set("email", $email);
}


// Get Avatar
$avatarPath = "https://graph.facebook.com/$userID/picture?type=large";
$file = ParseFile::createFromFile($avatarPath, "avatar.jpg");
$file->save();
$url = $file->getURL();
$currentUser->set("avatar", $file);
       
// Save other data
$currentUser->set("isReported", false);
$currentUser->set("fullName", $fullname);
$currentUser->setArray("hasBlocked", array());

/*
print_r($username.'<br>');
print_r($email.'<br>');
// print_r($fullname.'<br>');
echo '<img src="https://graph.facebook.com/'.$userID.'/picture?type=large">';
*/

try {
    $currentUser->save();
    // Go back to index.php
    header("Refresh:1; url=index.php");
	
    echo '
        <div class="text-center">
            <div class="alert alert-success">You have logged in with Facebook, please wait...</div>
        </div>
    ';
    // error
    } catch (ParseException $ex) {  
		// Go back to index.php
    	header("Refresh:1; url=index.php");
				
		echo '
            <div class="text-center">
                <div class="alert alert-danger">
                    <em class="fa fa-exclamation"></em> '.$ex->getMessage().'
                </div>
             </div>
        ';				 
}
?>
<?php else: ?> 
<?php endif ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" name="viewport" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

<title>My Stream | A place for your creativity</title>

<!-- Favicons -->
<link rel="apple-touch-icon" href="assets/img/apple-icon.png">
<link rel="icon" href="assets/img/favicon.png">

<!-- Fonts and icons     -->
<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Roboto+Slab:400,700|Material+Icons" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css" />

<!-- Material Kit CSS -->
<link rel="stylesheet" href="assets/css/material-kit.css?v=2.0.0">

</head>
<body>




<!--  Javascript   -->
<script src="assets/js/core/jquery.min.js"></script>
<script src="assets/js/core/popper.min.js"></script>
<script src="assets/js/bootstrap-material-design.js"></script>

<!--  Plugin for Date Time Picker and Full Calendar Plugin  -->
<script src="assets/js/plugins/moment.min.js"></script>

<!--    Plugin for the Datepicker, full documentation here: https://github.com/Eonasdan/bootstrap-datetimepicker -->
<script src="assets/js/plugins/bootstrap-datetimepicker.min.js"></script>

<!--    Plugin for the Sliders, full documentation here: http://refreshless.com/nouislider/ -->
<script src="assets/js/plugins/nouislider.min.js"></script>

<!-- Material Kit Core initialisations of plugins and Bootstrap Material Design Library -->
<script src="assets/js/material-kit.js?v=2.0.0"></script>

</body>
</html>