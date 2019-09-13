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
use Parse\ParseGeoPoint;
use Parse\ParseClient;
use Parse\ParseSessionStorage;
session_start();

/* Variables */
$sObjID = $_GET['sObjID'];
$sObj = new ParseObject('Streams', $sObjID);
$sObj->fetch();
try {
  $sObj->destroy();
  echo 'Stream successfully deleted!';

// error on saving 
} catch (ParseException $ex) { echo $ex->getMessage(); }
?>