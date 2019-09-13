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

    /* Variables */
    $currUser = ParseUser::getCurrentUser();
    
    $username = $_GET['username'];
    $fullName = $_GET['fullName'];
    $email = $_GET['email'];
    $aboutMe = $_GET['aboutMe'];
    
    $currUser->set('username', $username);
    $currUser->set('fullName', $fullName);
    $currUser->set('email', $email);
    $currUser->set('aboutMe', $aboutMe);

    // Save avatar
    $avatarURL = $_GET['avatarURL'];
    if ($avatarURL != '') {
        $file = ParseFile::createFromFile($avatarURL, "avatar.jpg");
        $file->save();
        $currUser->set("avatar", $file);    
    }

    // Save cover
    $coverURL = $_GET['coverURL'];
    if ($coverURL != '') {
        $file = ParseFile::createFromFile($coverURL, "cover.jpg");
        $file->save();
        $currUser->set("cover", $file);    
    }

    try {
        $currUser->save();
        echo 'Your profile has been updated';

    // error
    } catch ( ParseException $e){ echo $e->getMessage(); }
?>



