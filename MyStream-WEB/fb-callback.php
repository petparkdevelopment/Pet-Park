<?php
require_once 'fb-autoload.php';
include 'Configs.php';

error_reporting(E_ALL);
ini_set("display_errors", 1);

// Init PHP Sessions
use Facebook\Exceptions\FacebookResponseException;
use Facebook\Exceptions\FacebookSDKException;

$fb = new Facebook\Facebook([
  'app_id' => $_GLOBALS["FACEBOOK_APP_ID"],
  'app_secret' => $_GLOBALS["FACEBOOK_APP_SECRET"],
  'default_graph_version' => 'v2.3',
]);

$helper = $fb->getRedirectLoginHelper();

if (isset($_GET['state'])) {
    $helper->getPersistentDataHandler()->set('state', $_GET['state']);
}

try {
  $accessToken = $helper->getAccessToken($_GLOBALS['FACEBOOK_CALLBACK_URL']);

} catch(Facebook\Exceptions\FacebookResponseException $e) {
  // When Graph returns an error
  echo 'Graph returned an error: ' . $e->getMessage();
  exit;
} catch(Facebook\Exceptions\FacebookSDKException $e) {
  // When validation fails or other local issues
  echo 'Facebook SDK returned an error: ' . $e->getMessage();
  exit;
}

if (! isset($accessToken)) {
  if ($helper->getError()) {
    header('HTTP/1.0 401 Unauthorized');
    echo "Error: " . $helper->getError() . "\n";
    echo "Error Code: " . $helper->getErrorCode() . "\n";
    echo "Error Reason: " . $helper->getErrorReason() . "\n";
    echo "Error Description: " . $helper->getErrorDescription() . "\n";
  } else {
    header('HTTP/1.0 400 Bad Request');
    echo 'Bad request';
  }
  exit;
}

// LOGGED IN!
// The OAuth 2.0 client handler helps us manage access tokens
$oAuth2Client = $fb->getOAuth2Client();
// Get the access token metadata from /debug_token
$tokenMetadata = $oAuth2Client->debugToken($accessToken);

// Validation (these will throw FacebookSDKException's when they fail)
$tokenMetadata->validateAppId($_GLOBALS["FACEBOOK_APP_ID"]); 
$tokenMetadata->validateExpiration();

if (! $accessToken->isLongLived()) {
  // Exchanges a short-lived access token for a long-lived one
  try {
    $accessToken = $oAuth2Client->getLongLivedAccessToken($accessToken);
  } catch (Facebook\Exceptions\FacebookSDKException $e) {
    echo "<p>Error getting long-lived access token: " . $helper->getMessage() . "</p>\n\n";
    exit;
  }
}

$_SESSION['fb_access_token'] = (string) $accessToken;


// CHECK IF SESSION IS OK, GET GRAPH OBJECT AND GO BACK TO login.php
if (isset($_SESSION)) {

  $response = $fb->get('/me?fields=id,name,email', $accessToken);
  $node = $response->getGraphNode();

  // Get ID, Name and Email of Facebook user
  $fbid = $node->getField('id');         // To Get Facebook ID
  $fbfullname = $node->getField('name'); // To Get Facebook full name
  $femail = $node->getField('email');    // To Get Facebook email ID
  // $token = $session->getToken(); // Get Access Token
  $token = $_SESSION['fb_access_token'];

  // ---- Session Variables -----
  $_SESSION['FBID'] = $fbid;
  $_SESSION['FULLNAME'] = $fbfullname;
  $_SESSION['EMAIL'] =  $femail;
  $_SESSION['TOKEN'] = $token;

  // ---- GO TO fb-login-confirm.php ----
	header("Location: fb-login-confirm.php");

} else {
    $loginUrl = $helper->getLoginUrl();
    header("Location: ".$loginUrl);
}
?>
