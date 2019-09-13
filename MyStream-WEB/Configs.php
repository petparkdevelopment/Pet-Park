<?php
require 'autoload.php';

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

ParseClient::initialize(

	// REPLACE THIS STRING WITH YOUR OWN App Id FROM back4app
	'LShV0Q5wA4FwXCjTmblIXRLuOkc52NR6aEbhzpyU', 
	
	// REPLACE THIS STRING WITH YOUR OWN Rest API Key FROM back4app
	'dT80vO9I5wH2dQN4Ypul1yb4E9a18UGAamzwRH69', 

	// REPLACE THIS STRING WITH YOUR OWN Masketr Key FROM back4app
	'RyQdN5NVJPbhXJklpt8ZOUDJGSJK3DFbdxM8FaHI' );


ParseClient::setServerURL('https://parseapi.back4app.com','/');
ParseClient::setStorage( new ParseSessionStorage() );


// IMPORTANT: REPLACE THE STRING BELOW WITH THE FULL URL OF THE ROOT OF YOUR WEBSITE: 
$GLOBALS['WEBSITE_PATH'] = 'https://www.cubycode.com/mystream/';


// IMPORTANT: REPLACE THE STRINGS BELOW WITH THE LINKS TO YOUR IOS AND ANDROID APP VERSIONS:
$_GLOBALS['IOS_APPSTORE_LINK'] = "https://itunes.apple.com/us/app/cubimaze-an-impossible-memory-puzzle-game/id1253850533?mt=8";
$_GLOBALS["ANDROID_PLAYSTORE_LINK"]	= "https://play.google.com/store/apps/details?id=com.fvimagination.cubimaze";


//IMPORTANT: REPLACE THE STRING BELOW WITH YOUR OWN FACEBOOK AP ID AND SECRET KEY:
$_GLOBALS["FACEBOOK_APP_ID"] = "536439996718120";
$_GLOBALS["FACEBOOK_APP_SECRET"] = "af4badda7274ddb46e5eb1d08c693eea";


$_GLOBALS['FACEBOOK_CALLBACK_URL'] = $GLOBALS['WEBSITE_PATH'].'fb-callback.php';
?>