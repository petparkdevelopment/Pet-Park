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
$sObjID = $_GET['sObjID'];
$comment = $_GET['comment'];

// Get Stream Object
$sObj = new ParseObject("Streams", $sObjID);
$sObj->fetch();

// Get Current user
$currUser = ParseUser::getCurrentUser();
$cuObjectID = $currUser->getObjectId();
$cuFullname = $currUser->get('fullName');

// Get Stream userPointer
$userPointer = $sObj->get("userPointer");
$userPointer->fetch();
$upObjID = $userPointer->getObjectId();

// Create Parse object
$cObj = new ParseObject('Comments');
// Save data
$cObj->set('streamPointer', $sObj);
$cObj->set('comment', $comment);
$cObj->set('userPointer', $currUser);
$reportedBy = array();
$cObj->setArray('reportedBy', $reportedBy);

// saving block
try {
  $cObj->save();
	
  // Increment comments amount for this Stream
  $sObj->increment('comments', 1);
  $sObj->save();
  
  // Send Push Notification
  $pushMessage = $cuFullname.' commented your Stream: '.$sObj->get('text');
  $alert = array("alert" => $pushMessage);

  // Send Push to iOS and Android devices
  ParseCloud::run( "push", array("someKey" => $upObjID, "data" => $alert) );
  ParseCloud::run( "pushAndroid", array("someKey" => $upObjID, "data" => $alert) );
  
  // Save Activity
  $actObj = new ParseObject('Activity');
  $actObj->set('currUser', $streamPointer);
  $actObj->set('otherUser', $currUser);
  $actObj->set('text', $pushMessage);
  $actObj->save();
  
// error on saving 
} catch (ParseException $ex) { echo $ex->getMessage(); }
?>