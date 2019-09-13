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

echo '
  <!-- navbar -->
  <nav class="navbar fixed-top  navbar-expand-lg "  color-on-scroll="100"  id="sectionsNav">

    <div class="container">
        <div class="navbar-translate">
            <a class="navbar-brand" href="index.php"> <img src="assets/img/favicon.png" width="35"> <strong style="font-size: 22px;"> MyStream</strong></a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
                <span class="navbar-toggler-icon"></span>
                <span class="navbar-toggler-icon"></span>
            </button>
        </div>

        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ml-auto">

              <!-- search form -->
              <form class="form-inline ml-auto" action="index.php">
                <div class="form-group">
                  <input type="text" name="keywords" class="form-control" placeholder="Search...">
                </div>
              </form><!-- /. search form -->

              <li class="nav-item">
                <a class="nav-link" rel="tooltip" title="" data-placement="bottom" href="index.php" data-original-title="Explore">
                  <img src="assets/img/home_butt.png">
                </a>
              </li>

              <li class="nav-item">
                <a class="nav-link" rel="tooltip" title="" data-placement="bottom" href="following.php" data-original-title="Following Streams">
                  <img src="assets/img/follow_butt.png">
                </a>
              </li>

              <li class="nav-item">                
                <a id="notifications" class="nav-link" rel="tooltip" data-toggle="popover" data-placement="bottom" data-html="true" title="Notifications" data-container="body"><img src="assets/img/notifications_butt.png"></a>
                </a>
              </li>

              <li>
                <a href="account.php" class="nav-link" rel="tooltip" title="" data-placement="bottom" data-original-title="Account">'; 
                    $currUser = ParseUser::getCurrentUser();
                    if ($currUser != null) {
                      $cuAvatarFile = $currUser->get('avatar');
                      $cuAvatarURL = $cuAvatarFile->getURL();
                      echo '<img src="'.$cuAvatarURL.'" width="30" class="rounded-circle img-fluid center-cropped-image-30">';
                    }
                    echo '
                </a>
              </li>

            </ul>
        </div>
    </div>
</nav><!-- ./ navbar -->
';

?>