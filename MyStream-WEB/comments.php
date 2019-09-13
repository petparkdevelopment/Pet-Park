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

// Redirect to login.php in case of User NOT logged in
$currUser = ParseUser::getCurrentUser();
if ($currUser == null) { header('Refresh:0; url=login.php'); }
?>

<!-- header -->  
<?php include 'header.php'; ?>

<body class="landing-page ">

<!-- navbar -->
<?php include 'navbar.php'; ?>


<!-- main-raised -->
<div class="main main-raised" style="margin-top: 100px;">
	<div class="container">

      <?php
        // Get Parse Obj
        $sObjID = $_GET['sObjID'];
        $sObj = new ParseObject('Streams', $sObjID);
        $sObj->fetch();
        $sText = $sObj->get('text');
        
        // Get userPointer
        $userPointer = $sObj->get("userPointer");
        $userPointer->fetch();
        $upFullname = $userPointer->get('fullName');

        $currUser = ParseUser::getCurrentUser();
        $currUserID = $currUser->getObjectId();

        echo '
          <div class="text-center"><br>
            <h3 class="title">Comments</h3>
            <hr>
            <h4><strong>'.$upFullname.'</strong></h4>
            <em>'.$sText.'</em>
          </div>
        ';

        // Query Comments
        try {
          $query = new ParseQuery('Comments');
          $query->equalTo('streamPointer', $sObj);
          $query->notContainedIn('reportedBy', [$currUserID]);
          $query->descending('createdAt');
          $commArray = $query->find();    

          for ($i = 0;  $i < count($commArray); $i++) {
                // Get Parse Object
                $cObj = $commArray[$i];
                $cObjID = $cObj->getObjectId();
                // Get row
                $sRow = $i;

                // Get comment
                $cComment = $cObj->get('comment');

                // Get date and format it
                $date = $cObj->getCreatedAt();
                $aDate = date_format($date,"Y/m/d H:i:s");

                // Get userPointer
                $cUserPointer = $cObj->get("userPointer");
                $cUserPointer->fetch();
                $cUserPointerID = $cUserPointer->getObjectId();
                $cupFullname = $cUserPointer->get('fullName');
                $cupUsername = $cUserPointer->get('username');
                $cupAvatarFile = $cUserPointer->get('avatar');
                $cupAvatarURL = $cupAvatarFile->getURL();

                echo '
                  <!-- comment row -->
                  <div class="row">
                    <div class="col-md-6 ml-auto mr-auto">
                      <div class="comment">
                        <a href="user-profile.php?userID='.$cUserPointerID.'"><img src="'.$cupAvatarURL.'" width="50" class="img-raised rounded-circle img-fluid center-cropped-image-60"></a>
                        <span class="info-title">'.$cupFullname.'</span>  
                        <p style="margin-top: 20px;">'.$cComment.'</p>
                        <span style="font-size: 12px;">2 hours ago
                          <a href="#mystream" style="float: right;" onclick="reportComment(\''.$cObjID.'\', \''.$sRow.'\')"><img src="assets/img/report_butt.png"></a></span>
                          <hr>
                      </div>
                    </div><!-- ./ col 12 -->
                  </div><!-- ./ comment row -->
                ';
              }

        // error in query
        } catch (ParseException $e){ echo $e->getMessage(); }

        // Write comment form
        echo '
          <hr>
          <div class="text-center">
            <h4 class="title">Write a comment</h4>
          </div>
          <iframe name="myframe" style="display:none;"></iframe>
          <form action="add-comment.php" target="myframe">
            <div class="form-group">
              <div class="col-md-6 ml-auto mr-auto">
                <textarea name="comment" rows="1" class="form-control" placeholder="Your comment ..."></textarea>
              </div>
            </div>
            <!-- Hidden inputs -->
            <input type="hidden" name="sObjID" value="'.$sObjID.'">
            <div class="text-center">
              <input type="submit" value="Send Comment" class="btn btn-primary" onclick="showLoadingModalReloadPage()">
            </div>
          </form>
          <hr>
        ';
      ?>


    </div><!-- ./ container -->
</div><!-- ./ main-raised -->



<!-- notifications popover -->
<div id="popover-content-notifications" style="display: none;">
  <?php

    $currUser = ParseUser::getCurrentUser();
    
    // User is not logged in...
    if ($currUser != null) {

      // Query Activity
      try {
        $query = new ParseQuery('Activity');
        $query->equalTo('currentUser', $currUser);
        $query->descending('createdAt');
        $actArray = $query->find();    

        for ($i = 0;  $i < count($actArray); $i++) {
              // Get Parse Object
              $aObj = $actArray[$i];
              
              // Get text
              $aText = $aObj->get('text');

              // Get date and format it
              $date = $aObj->getCreatedAt();
              $aDate = date_format($date,"Y/m/d H:i:s");

              // Get streamPointer
              $streamPointer = $aObj->get("streamPointer");
              $streamPointer->fetch();
              $streamPointerID = $streamPointer->getObjectId();

              // Get otherUser
              $otherUser = $aObj->get("otherUser");
              $otherUser->fetch();
              $otherUserID = $otherUser->getObjectId();
              $ouFullname = $otherUser->get('fullName');
              $ouUsername = $otherUser->get('username');
              $avatarFile = $otherUser->get('avatar');
              $avatarURL = $avatarFile->getURL();

              $aTextNoName = str_replace($ouFullname, "", $aText);

              echo '
                <!-- notification row -->
                <div class="row">
                  <div class="col-sm-1">
                    <!-- avatar -->
                    <a href="user-profile.php?userID='.$otherUserID.'"><img src="'.$avatarURL.'" width="30" class="rounded-circle img-fluid"></a>   
                  </div>
                  <div class="col-sm-10">
                    <!-- fullname -->
                    <a href="user-profile.php?userID='.$otherUserID.'" style="color: #000;"><strong>'.$ouFullname.'</strong></a>
                    <!-- activity text -->
                    <a href="stream-details.php?sObjID='.$streamPointerID.'" style="color: #555;">'.$aTextNoName.'</a>
                  </div>
                </div><!-- /. row -->
                <hr><!-- line -->
              ';
            }

      // error in query
      } catch (ParseException $e){ echo $e->getMessage(); }

    }// end IF
  ?>

</div><!-- ./ notifications popover -->


<!-- footer -->
<?php include 'footer.php'; ?>

<!-- Javascript -->

<!-- Notifications popover -->
<script>
  $("[data-toggle=popover]").each(function(i, obj) {
  $(this).popover({
    html: true,
    content: function() {
      var id = $(this).attr('id')
      return $('#popover-content-' + id).html();
    }
  });
});
</script>

</body>
</html>