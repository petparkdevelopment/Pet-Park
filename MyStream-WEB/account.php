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
?>

<!-- header -->  
<?php include 'header.php'; ?>

<body class="profile-page ">

<!-- navbar -->
<?php include 'navbar-account.php'; ?>


<?php 
  // Current User details
  $currUser = ParseUser::getCurrentUser();
  $currUserID = $currUser->getObjectId();
  $cuFullname = $currUser->get('fullName');
  $cuUsername = $currUser->get('username');
  $cuCoverFile = $currUser->get('cover');
  if ($cuCoverFile != null) {
    $cuCoverURL = $cuCoverFile->getURL();
  } else {
    $cuCoverURL = 'assets/img/bg2.jpg';
  }
  $cuAvatarFile = $currUser->get('avatar');
  $cuAvatarURL = $cuAvatarFile->getURL();
  $cuAboutMe = $currUser->get('aboutMe');

  // Query Following
  try {
      $query = new ParseQuery('Follow');
      $query->equalTo('currUser', $currUser);
      $query->descending('createdAt');
      $followingArray = $query->find();   
      $followingNr = count($followingArray);

      // Query Followers
      try {
        $query = new ParseQuery('Follow');
        $query->equalTo('isFollowing', $currUser);
        $query->descending('createdAt');
        $followersArray = $query->find();   
        $followersNr = count($followersArray);

      // error
      } catch (ParseException $e){ echo $e->getMessage(); } 

    // error 
    } catch (ParseException $e){ echo $e->getMessage(); } 


  echo '
    <!-- cover image-->
    <div class="page-header header-filter" data-parallax="true" style="background-image: url('.$cuCoverURL.');"></div>

    <!-- main-raised -->
    <div class="main main-raised">
      <div class="container">
        <div class="row">
          <div class="col-md-6 ml-auto mr-auto">
            
            <div class="profile">
              <div class="avatar">
                <img src="'.$cuAvatarURL.'" class="img-raised rounded-circle img-fluid">
              </div>
              <div class="name">
                <h3 class="title">'.$cuFullname.'</h3>
                <h6 style="text-transform: lowercase;">@'.$cuUsername.'</h6>
                <a href="#mystream" class="btn btn-white" data-toggle="modal" data-target="#followingModal" style="color:#000;"><strong>'.$followingNr.'</strong> following</a>
                <a href="#mystream" class="btn btn-white" data-toggle="modal" data-target="#followersModal" style="color:#000;"><strong>'.$followersNr.'</strong> followers</a>
                <a href="#mystream" class="btn btn-white" style="color:#555;" data-toggle="modal" data-target="#settingsModal"><i class="material-icons">settings</i></a>
              </div>
            </div>

          </div><!-- ./ col -->
        </div><!-- ./ row -->

        <div class="description text-center">
          <p>'.$cuAboutMe.'</p>
        </div>
    ';
    ?>

    <hr><!-- ./ account header -->


    <h5 class="text-center title">My Stream</h5>
 
<?php
    
    $currUser = ParseUser::getCurrentUser();
    
    // User is logged in...
    if ($currUser != null) {
      $currUserID = $currUser->getObjectId();

      // Query streams
      try {
        $query = new ParseQuery('Streams');
        $query->equalTo('userPointer', $currUser);
        if ($keywords != null) { $query->containedIn('keywords', $keywArr); }
        $query->limit(1000);
        $query->descending('createdAt');
        $streamsArray = $query->find();    
        
        if (count($streamsArray) == 0) {
          echo '<br><br><h5 class="text-center">You have no streams yet.<br>Post something from the app now!</h5><br><br>';
        } else {

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

             
                echo '
                <!-- stream row -->
                <div class="row" id="'.$sObjID.'">
                  <div class="col-md-6 ml-auto mr-auto">
                    <div class="stream">
                      <img src="'.$cuAvatarURL.'" class="img-raised rounded-circle img-fluid center-cropped-image-50">
                      <span class="info-title">'.$cuFullname.'</span>  
                      <p style="font-size: 12px;margin:-20px 0px 0px 53px;">@'.$cuUsername.' • '.time_ago($sDate).'</p><br>
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
                          <a href="#mystream" class="dropdown-toggle" data-toggle="dropdown" style="color: #000; font-size: 25px; float:right;">•••</a>
                          <span class="dropdown-menu dropdown-menu-center">
                            <a href="#mystream" class="dropdown-item" onclick="deleteStream(\''.$sObjID.'\', \''.$sRow.'\')">
                            <img src="assets/img/delete_butt.png">&nbsp;&nbsp;&nbsp; Delete Stream</a>
                          
                          </span>
                        </span>
                        <hr>
                      </div>
                    </div><!-- ./ col 12 -->
                  </div><!-- ./ stream row -->
                ';
            
              }// ./ IF

        }// ./ FOR loop
    
      // error in query
      } catch (ParseException $e){ echo $e->getMessage(); }

    }// end IF
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



<!-- settingsModal -->
<div class="modal fade" id="settingsModal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-body">
        <a href="edit-profile.php" class="btn btn-white btn-block">Edit profile</a>
        <a href="tou.html" class="btn btn-white btn-block">Terms of Use</a>
        <a href="https://www.facebook.com/cubycodeapps" target="_blank" class="btn btn-white btn-block">Like on Facebook</a>
        <a href="https://twitter.com/cubycode" target="_blank" class="btn btn-white btn-block">Follow on Twitter</a>
        <a href="#mystream" class="btn btn-white btn-block" onclick="logOut()">Logout</a>
        <a class="btn btn-primary btn-block" data-dismiss="modal" style="color: #fff;">Cancel</a>
      </div>
    </div>
  </div>
</div><!-- ./ settingsModal -->



<!-- followingModal -->
<div class="modal fade" id="followingModal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content-follow">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="material-icons">clear</i>
        </button>
      </div>
      <div class="modal-body">
        <h4 class="modal-title text-center"><strong>Following</strong></h4>
        <hr>
        
        <?php
          for ($i = 0;  $i < count($followingArray); $i++) {
            // Get Parse Obj
            $followingObj = $followingArray[$i];

            // Get Following User
            $followingUser = $followingObj->get("isFollowing");
            $followingUser->fetch();
            $finguUserID = $followingUser->getObjectId();
            $finguFullname = $followingUser->get('fullName');
            $finguUsername = $followingUser->get('username');
            $finguAvatarFile = $followingUser->get('avatar');
            $finguAvatarURL = $finguAvatarFile->getURL();
            $finguAboutMe = $followingUser->get('aboutMe');
        
            echo '
              <!-- following row -->
              <a href="user-profile.php?userID='.$finguUserID.'">
                <img src="'.$finguAvatarURL.'" class="rounded-circle img-fluid center-cropped-image-30"></a>   
              &nbsp;&nbsp;<span><a href="user-profile.php?userID='.$finguUserID.'" style="color: #000;"><strong>'.$finguFullname.'</strong></a></span>
              &nbsp;&nbsp;
              <span class="p">@'.$finguUsername.'</span>
              <p>'.$finguAboutMe.'</p>       
              <hr><!-- /. following row -->
            ';
          }
        ?>
      </div>
    </div>
  </div>
</div><!-- ./ followModal -->


<!-- followersModal -->
<div class="modal fade" id="followersModal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content-follow">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="material-icons">clear</i>
        </button>
      </div>
      <div class="modal-body">
        <h4 class="modal-title text-center"><strong>Followers</strong></h4>
        <hr>

        <?php
          for ($i = 0;  $i < count($followersArray); $i++) {
            // Get Parse Obj
            $followerObj = $followersArray[$i];

            // Get Following User
            $followerUser = $followerObj->get("currUser");
            $followerUser->fetch();
            $fweruUserID = $followerUser->getObjectId();
            $fweruFullname = $followerUser->get('fullName');
            $fweruUsername = $followerUser->get('username');
            $fweruAvatarFile = $followerUser->get('avatar');
            $fweruAvatarURL = $fweruAvatarFile->getURL();
            $fweruAboutMe = $followerUser->get('aboutMe');
        
            echo '
              <!-- follower row -->
              <a href="user-profile.php?userID='.$fweruUserID.'">
                <img src="'.$fweruAvatarURL.'" class="rounded-circle img-fluid center-cropped-image-30"></a>   
              &nbsp;&nbsp;<span><a href="user-profile.php?userID='.$fweruUserID.'" style="color: #000;"><strong>'.$fweruFullname.'</strong></a></span>
              &nbsp;&nbsp;
              <span class="p">@'.$fweruUsername.'</span>
              <p>'.$fweruAboutMe.'</p>       
              <hr><!-- /. follower row -->
            ';
          }
        ?>
      </div>
    </div>
  </div>
</div><!-- ./ followModal -->
<!-- footer -->
<?php include 'footer.php'; ?>
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


<!-- Magnific Popup -->
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


// LIKE STREAM -------------------------------                    
function likeStream(sObjID, sLikes, sRow) {  
  // Show loading modal
  document.getElementById('loadingText').innerHTML = " Please wait...";
  $('#loadingModal').modal('show'); 

  $.ajax({
    url:"like-stream.php?sObjID=" + sObjID,  
    type: "GET", 
    success:function(data) {
    var results = data.replace(/\s+/, ""); //remove any white spaces from the returned string    
    // Format results to split LIKE and likes amount
    var res = results.split("-");

    // LIKE 
    if (res[0] == "LIKE") {
      $("#likeButton" + sRow).attr('src', 'assets/img/liked_butt.png');
      
    // UNLIKE
    } else if (res[0] == "UNLIKE") {
      $("#likeButton" + sRow).attr('src', 'assets/img/like_butt.png');
    }
    
    // Show likes amount
    document.getElementById("likes" + sRow).innerHTML = res[1];
    console.log("LIKES: " + res[1]);
    // Hide loadingModal
    $('#loadingModal').modal('hide'); 
  }});
}


// DELETE STREAM -------------------------------                    
function deleteStream(sObjID, sRow) {  
  // Show loading modal
  document.getElementById('loadingText').innerHTML = " Deleting Stream...";
  $('#loadingModal').modal('show'); 

  $.ajax({
    url:"delete-stream.php?sObjID=" + sObjID,  
    type: "GET", 
    success:function(data) {
    var results = data.replace(/\s+/, ""); //remove any white spaces from the returned string    
    console.log(data);

    // Hide loadingModal
    $('#loadingModal').modal('hide'); 

    // Show Alert
    alert(data);

    // Reload page
    setTimeout(function(){
      location.reload(); 
    }, 500);

  }});
}

// SHOW LOADING MODAL ------------------------------------
function showLoadingModal() {
  $('#loadingModal').modal('show');
  /*
  setTimeout(function(){
      location.reload(); 
  }, 500);
  */      
}
</script>

</body>
</html>