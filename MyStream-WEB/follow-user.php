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

// Get data
$uObjID = $_GET['uObjID'];
	
// Get current User 
$currUser = ParseUser::getCurrentUser();
$currUserID = $currUser->getObjectId();
$currUserFullname = $currUser->get('fullName');

// Get userObj
$userObj = new ParseObject("_User", $uObjID);
$userObj->fetch();

// Query Follow
try {
	$query = new ParseQuery('Follow');
	$query->equalTo('currUser', $currUser);
	$query->equalTo('isFollowing', $userObj);
	$fArray = $query->find();

	// Unfollow   
	if (count($fArray) != 0) {
		 $fObj = $fArray[0];
		 $fObj->destroy();
		 echo 'UNFOLLOW';

	// Follow
	} else {
	    $fObj = new ParseObject('Follow');
		$fObj->set('currUser', $currUser);
		$fObj->set('isFollowing', $userObj);
		try {
			$fObj->save();
			echo 'FOLLOW';


			// Send Push Notification
			$pushMessage = $currUserFullname.' started following you';
			$alert = array("alert" => $pushMessage);

			// Send Push to iOS and Android devices
			ParseCloud::run( "push", array("someKey" => $uObjID, "data" => $alert) );
			ParseCloud::run( "pushAndroid", array("someKey" => $uObjID, "data" => $alert) );

		// error
	    } catch ( ParseException $e){ echo $e->getMessage(); }
	}
// error
} catch ( ParseException $e){ echo $e->getMessage(); }
?>