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

    $currUser = ParseUser::getCurrentUser();
    $tempStreamsArray = array();
    $streamsArray = array();

    // User is logged in...
    if ($currUser != null) {
      $currUserID = $currUser->getObjectId();

      // Query Following Streams
      try {
        $query = new ParseQuery('Follow');
        $query->equalTo('currUser', $currUser);
        $query->limit(1000);
        $followArray = $query->find();    
        
        // You're following someone
        if (count($followArray) != 0) {

          for ($i = 0;  $i < count($followArray); $i++) {
                // Get Parse Object
                $fObj = $followArray[$i];
                
                // Get userPointer
                $userPointer = $fObj->get("isFollowing");
                $userPointer->fetch();
                $upIsReported = $userPointer->get('isReported');
                if ($upIsReported == false) {
                  $query = new ParseQuery('Streams');
                  $query->equalTo('userPointer', $userPointer);
                  $query->notContainedIn('reportedBy', [$currUserID]);
                  $query->limit(1000);
                  $tempStreamsArray = $query->find(); 
                	
									// Get streamsArray
									$streamsArray = array_merge($tempStreamsArray, $streamsArray);
						
						    }// end IF
								
						}// end FOR loop
					
					
					
            for ($i = 0;  $i < count($streamsArray); $i++) {

                     // Get Parse Object
                    $sObj = $streamsArray[$i];
                    // Get stream ID
                    $sObjID = $sObj->getObjectId();
                    // Get row
                    $sRow = $i;
                    // Get text
                    $sText = $sObj->get('text');
                    // Get likes
                    $sLikes = $sObj->get('likes');
                    // Get comments
                    $sComments = $sObj->get('comments');
                    // Get date and format it
                    $date = $sObj->getCreatedAt();
                    $sDate = date_format($date,"Y/m/d H:i:s");
                    // Get likedBy 
                    $likedBy = $sObj->get("likedBy");

                    // Get userPointer
                    $userPointer = $sObj->get("userPointer");
                    $userPointer->fetch();
                    $upFullname = $userPointer->get('fullName');
                    $upUsername = $userPointer->get('username');
                    $upObjectID = $userPointer->getObjectId();
                    $avatarFile = $userPointer->get('avatar');
                    $avatarURL = $avatarFile->getURL();

                    echo '
                    <!-- stream row -->
                    <div class="row" id="'.$sObjID.'">
                      <div class="col-md-6 ml-auto mr-auto">
                        <div class="stream">
                          <a href="user-profile.php?userID='.$upObjectID.'">
                          <img src="'.$avatarURL.'" class="img-raised rounded-circle img-fluid center-cropped-image-50"></a>
                          <span class="info-title">'.$upFullname.'</span>  
                          <p style="font-size: 12px; margin:-20px 0px 0px 53px;">@'.$upUsername.' • '.time_ago($sDate).'</p><br>
                          ';

                          // Show image
                          if ($sObj->get('image') != null && $sObj->get('audio') == null && $sObj->get('video') == null) {
                            $sImage = $sObj->get('image');
                            $imageURL = $sImage->getURL();
                            echo '<a class="image-link" href="'.$imageURL.'"><img src="'.$imageURL.'" class="rounded img-fluid"></a>';
                          }

                          // Show audio
                          if ($sObj->get('audio') != null) {
                            $sAudio = $sObj->get('audio');
                            $audioURL = $sAudio->getURL();
                            echo '
                              <audio id="player'.$sObjID.'" ontimeupdate="updateTime(\''.$sObjID.'\')" src="'.$audioURL.'"></audio>
                              <a class="btn btn-primary btn-round" id="songPlay" onclick="play(';
                              echo "'player".$sObjID."'";
                              echo ')"><i class="fa fa-play"></i></a>
                              <a class="btn btn-primary btn-round" id="songPause" onclick="pause()"><i class="fa fa-pause"></i></a>
                              <a class="btn btn-primary btn-round" id="songStop" onclick="stopSong()"><i class="fa fa-stop"></i></a>
                              <div id="songTime'.$sObjID.'"><strong>0:00 / 0:00</strong></div>
                              <div id="songSlider'.$sObjID.'" class="songSlider" onclick="setSongPosition(this,event)">
                                <div id="trackProgress'.$sObjID.'" class="trackProgress"></div>
                              </div>
                              ';
                          }

                          // Show video
                          if ($sObj->get('video') != null) {
                            $sVideo = $sObj->get('video');
                            $videoURL = $sVideo->getURL();
                            $videoThumb = $sObj->get('image');
                            $thumbURL = $videoThumb->getURL();
                            echo '
                              <div>
                                <video id="media-video" controls style="max-width: 400px; border-radius: 8px;">
                                  <source src='.$videoURL.' type="video/mp4">
                                </video>
                              </div> 
                            ';
                          }

                          echo '
                            <p style="margin-top: 20px;">'.$sText.'</p>
                          ';

                          if (in_array($currUserID, $likedBy)) {
                            echo '
                              <a href="#mystream" id="likeButt'.$sRow.'" onclick="likeStream(\''.$sObjID.'\', \''.$sLikes.'\', \''.$sRow.'\')"><img id="likeButton'.$sRow.'" src="assets/img/liked_butt.png"></a> 
                            ';
                          } else {
                            echo '
                              <a href="#mystream" id="likeButt'.$sRow.'" onclick="likeStream(\''.$sObjID.'\', \''.$sLikes.'\', \''.$sRow.'\')"><img id="likeButton'.$sRow.'" src="assets/img/like_butt.png"></a> 
                            ';
                          }

                          echo '
                            <span id="likes'.$sRow.'">'.roundNumbersIntoKMGT($sLikes).'</span>
                            <span>&nbsp;&nbsp;&nbsp;&nbsp;
                            <a href="comments.php?sObjID='.$sObjID.'"><img src="assets/img/comments_butt.png"></a> '.$sComments.'
                            </span>
                            <span>&nbsp;&nbsp;&nbsp;&nbsp;
                              <a href="#mystream" class="dropdown-toggle" data-toggle="dropdown" style="color: #000; font-size: 25px;float:right;">•••</a>
                              <span class="dropdown-menu dropdown-menu-center">
                              ';
                              if ($upObjectID != $currUserID) {
                                echo '
                                  <a href="#mystream" class="dropdown-item" onclick="reportStream(\''.$sObjID.'\', \''.$sRow.'\')"><img src="assets/img/report_butt.png">&nbsp;&nbsp;&nbsp; Report Stream</a>
                                  <a href="#mystream" class="dropdown-item" onclick="reportUser(\''.$upObjectID.'\', \''.$sRow.'\')"><img src="assets/img/account_butt.png">&nbsp;&nbsp;&nbsp; Report '.$upFullname.'</a>';
                              } else {
                                echo '
                                  <a href="#mystream" class="dropdown-item" onclick="deleteStream(\''.$sObjID.'\', \''.$sRow.'\')">
                                  <img src="assets/img/delete_butt.png">&nbsp;&nbsp;&nbsp; Delete Stream</a>';
                              }

                          echo '
                              </span>
                            </span>
                            <hr>
                          </div>
                        </div><!-- ./ col 12 -->
                      </div><!-- ./ stream row -->
                    ';
              }// end FOR loop
                

        // You're not following anyone yet
        } else { echo '<h4>You are not following anyone yet.</h4>'; }
      
      // error in Following query
      } catch (ParseException $e){ echo $e->getMessage(); }

    }// end IF for currUser != null
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

<!-- Magnific Popup core JS file -->
<script src="assets/js/jquery.magnific-popup.min.js"></script>
<script>
  $(document).ready(function() {
    $('.image-link').magnificPopup({
      type:'image'
    });
    
    $('.popup-video').magnificPopup({
            disableOn: 700,
            type: 'iframe',
            mainClass: 'mfp-with-zoom',
            removalDelay: 300,
            preloader: false,
            fixedContentPos: false
    });
  }); 
</script>

<script>  
// CHECK SCREEN SIZE ------------------------------------
function checkScreenSize(){
    // Get the dimensions of the viewport
    var width = $(window).width();
    var height = $(window).height();

    $('#jqWidth').html(width);
    $('#jqHeight').html(height);

    // Load the mobile page (in case of mobile device)
    if(width < 767){ window.location.href = 'index-mobile.php'; }
    
};
$(document).ready(checkScreenSize);    // When the page first loads
$(window).resize(checkScreenSize);     // When the browser changes size
</script>


</body>
</html>