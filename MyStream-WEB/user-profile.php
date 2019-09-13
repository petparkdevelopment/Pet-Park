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

<body class="profile-page ">
<!-- navbar -->
<?php include 'navbar-user-profile.php'; ?>

<?php 
  // Get User details
  $userID = $_GET['userID'];
  $userObj = new ParseObject("_User", $userID);
  $userObj->fetch();
  $uFullname = $userObj->get('fullName');
  $uUsername = $userObj->get('username');
  $uCoverFile = $userObj->get('cover');
  $uCoverFile ? $uCoverURL = $uCoverFile->getURL() : $uCoverFile = '';
  $uAvatarFile = $userObj->get('avatar');
  $uAvatarURL = $uAvatarFile->getURL();
  $uAboutMe = $userObj->get('aboutMe');

  // Query Following
  try {
      $query = new ParseQuery('Follow');
      $query->equalTo('currUser', $userObj);
      $query->descending('createdAt');
      $followingArray = $query->find();   
      $followingNr = count($followingArray);

      // Query Followers
      try {
        $query = new ParseQuery('Follow');
        $query->equalTo('isFollowing', $userObj);
        $query->descending('createdAt');
        $followersArray = $query->find();   
        $followersNr = count($followersArray);

      // error
      } catch (ParseException $e){ echo $e->getMessage(); } 

    // error 
    } catch (ParseException $e){ echo $e->getMessage(); } 

  echo '
    <!-- cover image-->
    <div class="page-header header-filter" data-parallax="true" style="background-image: url('.$uCoverURL.');"></div>

    <!-- main-raised -->
    <div class="main main-raised">
      <div class="container">
        <div class="row">
          <div class="col-md-6 ml-auto mr-auto">
            
            <div class="profile">
              <div class="avatar">
                <img src="'.$uAvatarURL.'" class="img-raised rounded-circle img-fluid">
              </div>
              <div class="name">
                <h3 class="title">'.$uFullname.'</h3>
                <h6 style="text-transform: lowercase;">@'.$uUsername.'</h6>
                <a href="#mystream" class="btn btn-white" data-toggle="modal" data-target="#followingModal" style="color:#000;"><strong>'.$followingNr.'</strong> following</a>
                <a href="#mystream" class="btn btn-white" data-toggle="modal" data-target="#followersModal" style="color:#000;"><strong>'.$followersNr.'</strong> followers</a>
                <div class=text-center">';

                $currUser = ParseUser::getCurrentUser();
                $currUserID = $currUser->getObjectId();
                $following = 'following';
                $notfollowing = 'notfollowing';

                // Query is you Follow or not this User
                try {
                    $query = new ParseQuery('Follow');
                    $query->equalTo('currUser', $currUser);
                    $query->equalTo('isFollowing', $userObj);
                    $fArray = $query->find();   
                    if (count($fArray) != 0) {
                      echo '<a id="followButton" href="#mystream" class="btn btn-primary" onclick="followUser(\''.$userID.'\', \''.$following.'\')">Following</a>
                    ';
                    } else {
                      echo '<a id="followButton" href="#mystream" class="btn btn-white" style="color: #000" onclick="followUser(\''.$userID.'\', \''.$notfollowing.'\')">Follow</a>
                    ';
                    }
                  // error
                  } catch (ParseException $e){ echo $e->getMessage(); } 
                  
                  echo '
                  </div>
              </div>
            </div>

          </div><!-- ./ col -->
        </div><!-- ./ row -->

        <div class="description text-center">
          <p>'.$uAboutMe.'</p>
        </div>
    ';
    ?>

    <hr><!-- ./ account header -->


    <h5 class="text-center"><strong>Stream</strong></h5>
 
<?php
    
      // Query streams
      try {
        $query = new ParseQuery('Streams');
        $query->equalTo('userPointer', $userObj);
        $query->limit(1000);
        $query->descending('createdAt');
        $streamsArray = $query->find();    

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
                    <img src="'.$uAvatarURL.'" class="img-raised rounded-circle img-fluid center-cropped-image-50">
                    <span class="info-title">'.$uFullname.'</span>  
                    <p style="font-size: 12px;margin:-20px 0px 0px 53px;">@'.$uUsername.' • '.time_ago($sDate).'</p><br>
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
                        <audio id="player" ontimeupdate="updateTime()" src="'.$audioURL.'"></audio>
                        <a class="btn btn-primary btn-round" id="songPlay" onclick="play(';
                        echo "'player'";
                        echo ')"><i class="fa fa-play"></i></a>
                        <a class="btn btn-primary btn-round" id="songPause" onclick="pause()"><i class="fa fa-pause"></i></a>
                        <a class="btn btn-primary btn-round" id="songStop" onclick="stopSong()"><i class="fa fa-stop"></i></a>
                        <div id="songTime"><strong>0:00 / 0:00</strong></div>
                        <div id="songSlider" onclick="setSongPosition(this,event)"><div id="trackProgress"></div></div>
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
                        <a class="popup-video" href="'.$videoURL.'"><img src="'.$thumbURL.'" class="rounded img-fluid"></a>  
                        <div class="video-icon"><img src="assets/img/video_icon.png" style="margin-top: 50px;"></div>
                        </div>
                      ';
                    }

                    echo '
                      <p style="margin-top: 20px;">'.$sText.'</p>
                    ';

                    if (in_array($userID, $likedBy)) {
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
                          <a href="#mystream" class="dropdown-item" onclick="reportStream(\''.$sObjID.'\', \''.$sRow.'\')"><img src="assets/img/report_butt.png">&nbsp;&nbsp;&nbsp; Report Stream</a>
                          <a href="#mystream" class="dropdown-item" onclick="reportUser(\''.$userID.'\', \''.$sRow.'\')"><img src="assets/img/account_butt.png">&nbsp;&nbsp;&nbsp; Report '.$uFullname.'</a>
                        </span>
                      </span>
                      <hr>
                    </div>
                  </div><!-- ./ col 12 -->
                </div><!-- ./ stream row -->
              ';
            }

            // error in query
          } catch (ParseException $e){ echo $e->getMessage(); }

?>

    </div><!-- ./ container -->
</div><!-- ./ main-raised -->



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
</script>

</body>
</html>