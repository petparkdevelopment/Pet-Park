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

// Get Stream Object
$sObj = new ParseObject("Streams", $sObjID);
$sObj->fetch();

// Get currUser
$currUser = ParseUser::getCurrentUser();
$currUserID = $currUser->getObjectId();

// Get reportedBy array
$reportedBy = $sObj->get('reportedBy');

// Update reportedBy
array_push($reportedBy, $currUserID);
$sObj->setArray('reportedBy', $reportedBy);

try {
    $sObj->save();

    echo "Thanks for reporting this Stream. We'll check it out within 24h.";
// error
} catch ( ParseException $e){ echo $e->getMessage(); }
?>