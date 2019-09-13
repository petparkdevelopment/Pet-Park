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
$cObjID = $_GET['cObjID'];

// Get Comment Object
$cObj = new ParseObject("Comments", $cObjID);
$cObj->fetch();

// Get currUser
$currUser = ParseUser::getCurrentUser();
$currUserID = $currUser->getObjectId();

// Get reportedBy array
$reportedBy = $cObj->get('reportedBy');

// Update reportedBy
array_push($reportedBy, $currUserID);
$cObj->setArray('reportedBy', $reportedBy);

try {
    $cObj->save();

    echo "Thanks for reporting this Comment. We'll check it out within 24h.";
// error
} catch ( ParseException $e){ echo $e->getMessage(); }
?>