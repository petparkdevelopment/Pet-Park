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

// REQUIRE HTTPS
if ($_SERVER['HTTPS'] != "on") {
    $url = "https://". $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI'];
    header("Location: $url");
    exit;
}

// LOGIN ------------------------------------------
if(isset($_POST['username']) && isset($_POST['password']) ) {
    $username = $_POST['username'];
    $password = $_POST['password'];
        
    try {
        $user = ParseUser::logIn($username, $password); 

        // Go to index.php
        header('Refresh:0; url=index.php');

        echo '
            <div class="alert alert-success text-center">
                You have successfully logged in. <br>
                Please wait...
            </div>
        ';

    // error 
    } catch (ParseException $error) { $e = $error->getMessage();
        echo '
            <div class="alert alert-danger text-center">
            <em class="fa fa-exclamation"></em>
            '.$e.'
            </div>  
        '; 
    }
}




// FORGOT PASSWORD -----------------------------------
if( isset($_POST['email']) ) {
    $email = $_POST['email'];
    try {
        ParseUser::requestPasswordReset($email);
    
        echo '
                <div class="alert alert-success text-center">
                    Cool, you will get email shortly with a link to reset your password!
                </div>  
        '; 

    // error
    } catch (ParseException $error) { $e = $error->getMessage();
        
        echo '
            <div class="alert alert-danger">
            <em class="fa fa-exclamation"></em>
                '.$e.'
            </div>  
        '; 
    }
}
?>
<!-- header -->  
<?php include 'header.php'; ?>

<body class="landing-page ">
  
<div class="section section-signup page-header" style="background-image: url('assets/img/bg2.jpg');">
    <div class="container">
        <div class="row">
            <div class="col-md-6 ml-auto mr-auto">
                <div class="card card-signup">

                    <form class="form" action="login.php" method="post">
                        <div class="card-header card-header-primary text-center">
                            <h4>Sign in with</h4>
                            <div class="social-line">
                                <?php

                                    require_once 'fb-autoload.php';
                                    use Facebook\FacebookSession;
                                    use Facebook\FacebookRedirectLoginHelper;
                                    use Facebook\FacebookRequest;
                                    use Facebook\FacebookResponse;
                                    use Facebook\FacebookSDKException;
                                    use Facebook\FacebookRequestException;
                                    use Facebook\FacebookAuthorizationException;
                                    use Facebook\GraphObject;
                                    use Facebook\Entities\AccessToken;
                                    use Facebook\HttpClients\FacebookCurlHttpClient;
                                    use Facebook\HttpClients\FacebookHttpable;

                                    $fb = new Facebook\Facebook([
                                      'app_id'                => $_GLOBALS["FACEBOOK_APP_ID"],
                                      'app_secret'            => $_GLOBALS["FACEBOOK_APP_SECRET"],
                                      'default_graph_version' => 'v2.3',
                                    ]);



                                    $helper = $fb->getRedirectLoginHelper();

                                    $permissions = ['email']; // Optional permissions
                                    $loginUrl = $helper->getLoginUrl($GLOBALS['WEBSITE_PATH'].'fb-callback.php', $permissions);
                                    echo '
                                        <a class="btn btn-white btn-round" style="color: #000;" href="'.htmlspecialchars($loginUrl).'">
                                        <i class="fa fa-facebook"></i>&nbsp;&nbsp; Facebook</a>
                                    ';

                                    ?>
                            </div>
                        </div>

                        <p class="text-divider">Or Be Classical</p>
                        <div class="card-body">
                            <div class="input-group">
                                <span class="input-group-addon">
                                    <i class="material-icons">face</i>
                                </span>
                                <input type="text" name="username" class="form-control" placeholder="username">
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon">
                                    <i class="material-icons">lock_outline</i>
                                </span>
                                <input type="password" name="password" class="form-control" placeholder="password">
                            </div>
                        </div>
                        <div class="card-footer justify-content-center">
                            <input type="submit" value="login" class="btn btn-primary btn-block">
                        </div>
                    </form>
                </div>
            </div>

        </div><!-- /. row -->


    <!-- app store badges -->
    <h5 class="text-center">
        <strong>Get the mobile versions here:</strong>
    <br><br>
        <a href="<?php echo $_GLOBALS['IOS_APPSTORE_LINK'] ?>" target="_blank"><img src="assets/img/appstore-badge.png" width="140"></a>
        &nbsp; 
        <a href="<?php echo $_GLOBALS['ANDROID_PLAYSTORE_LINK'] ?>" target="_blank"><img src="assets/img/playstore-badge.png" width="140"></a>
    </h5>
    <br>

    </div><!-- /. container -->
</div><!-- /. section -->




<!-- footer -->  
<?php include 'footer.php'; ?>

</body>
</html>