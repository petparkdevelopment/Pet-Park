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
$userID = $_GET['userID'];
$reportMessage = 'Offensive User';
$currUser = ParseUser::getCurrentUser();
$currUserID = $currUser->getObjectId();


// Get User Object
$userObj = new ParseUser("_User", $userID);
$userObj->fetch();

// Set isReported to true for this User
ParseCloud::run( "reportUser", array("userId" => $userID, "reportMessage" => $reportMessage) );

// 1. Query and Report all Streams of this user (if any)
try {
    $query = new ParseQuery("Streams");
    $query->equalTo('userPointer', $userObj);
    $streamsArray = $query->find();      
        
    for ($i = 0;  $i < count($streamsArray); $i++) {
        $sObj = $streamsArray[$i];
        // Get reportedBy array
        $reportedBy = $sObj->get('reportedBy');
        
        // Update reportedBy
        array_push($reportedBy, $currUserID);
        $sObj->setArray('reportedBy', $reportedBy);
        
        try {
            $sObj->save();
            echo "STREAM REPORTED: ".$sObj->get('text')."\n";
        // error
        } catch ( ParseException $e){ echo $e->getMessage(); }
     }// end FOR loop

// error in query
} catch ( ParseException $e){ echo $e->getMessage(); }
?>