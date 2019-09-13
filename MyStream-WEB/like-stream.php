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

// Get the ObjID
$sObjID = $_GET['sObjID'];
	
// Get current User 
$currUser = ParseUser::getCurrentUser();
$currUserID = $currUser->getObjectId();
$currUserUsername = $currUser->get('username');
$currUserFullname = $currUser->get('fullName');

// Get Stream Object
$sObj = new ParseObject("Streams", $sObjID);
$sObj->fetch();

// Get likedBy array
$likedBy = $sObj->get("likedBy");
// Get Stream text
$sText = $sObj->get('text');


// Unlike Stream
if (in_array($currUserID, $likedBy)) {
	// Substract 1 like to the Ad
	$sObj->increment("likes", -1);
	// Remove the userObjID
	$likedBy = array_diff($likedBy, array($currUserID));

	// Update likedBy
	$sObj->setArray('likedBy', $likedBy);
	try {
		$sObj->save();
		
		// echo updated likes
		$likes = $sObj->get('likes');
		$likesRounded = roundNumbersIntoKMGT($likes);
		echo 'UNLIKE-'.$likesRounded;
	// error
    } catch ( ParseException $e){ echo $e->getMessage(); }


// Like Stream
} else {
	// Add 1 like to the Ad
	$sObj->increment("likes", 1);
	
	// Update likedBy 
	array_push($likedBy, $currUserID);
	$sObj->setArray('likedBy', $likedBy);

	try {
		$sObj->save();

		// Get userPointer
		$userPointer = $sObj->get("userPointer");
		$userPointer->fetch();
		$upObjID = $userPointer->getObjectId();

		// Send Push Notification
		$pushMessage = $currUserFullname.' liked your Stream: '.$sText;
		$alert = array("alert" => $pushMessage);

		// Send Push to iOS and Android devices
		ParseCloud::run( "push", array("someKey" => $upObjID, "data" => $alert) );
		ParseCloud::run( "pushAndroid", array("someKey" => $upObjID, "data" => $alert) );

		// Save Activity
	    $actObj = new ParseObject('Activity');
	    $actObj->set('currentUser', $userPointer);
	    $actObj->set('otherUser', $currUser);
	    $actObj->set('streamPointer', $sObj);
	    $actObj->set('text', $pushMessage);
	    $actObj->save();

	    // echo updated likes
		$likes = $sObj->get('likes');
		$likesRounded = roundNumbersIntoKMGT($likes);
		echo 'UNLIKE-'.$likesRounded;
	// error
    } catch ( ParseException $e){ echo $e->getMessage(); }
} 

// Round large numbers into KMGT
function roundNumbersIntoKMGT($n) {
  $n = (0+str_replace(",","",$n));
  if(!is_numeric($n)) return false;
  if($n>1000000000000) return round(($n/1000000000000),1).'T';
  else if($n>1000000000) return round(($n/1000000000),1).'G';
  else if($n>1000000) return round(($n/1000000),1).'M';
  else if($n>1000) return round(($n/1000),1).'K';
  return number_format($n);
}
?>