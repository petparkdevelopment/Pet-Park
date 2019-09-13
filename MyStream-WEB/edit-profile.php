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

<body class="landing-page ">

<!-- navbar -->  
<?php include 'navbar-editprofile.php'; ?>


<!-- main-raised -->
<div class="main main-raised" style="margin-top: 100px;">
	<div class="container">

    <div class="row">
      <div class="col-md-8 ml-auto mr-auto">
        <h3 class="text-center title">Edit Profile</h3>

        <?php
          // Current User details
          $currUser = ParseUser::getCurrentUser();
          $currUserID = $currUser->getObjectId();
          $cuFullname = $currUser->get('fullName');
          $cuUsername = $currUser->get('username');
          $cuEmail = $currUser->get('email');
          $cuCoverFile = $currUser->get('cover');
          $cuCoverURL = $cuCoverFile->getURL();
          $cuAvatarFile = $currUser->get('avatar');
          $cuAvatarURL = $cuAvatarFile->getURL();
          $cuAboutMe = $currUser->get('aboutMe');
        ?>



        <!-- Avatar image -->
        <div class="text-center">
          <img id="avatar-img" src="<?php echo $cuAvatarURL; ?>" class="rounded-circle img-fluid center-cropped-avatar" src="<?php echo $avatarURL ?>" height="64" width="64">
          <br>

          <div class="btn btn-white">Select avatar
            <input id="imageData" name="file" type="file" accept="image/*">
          </div>
        </div>

        <!-- AUTOMATICALLY UPLOAD SELECTED IMAGE -->
        <script>
        document.getElementById("imageData").onchange = function () {
          var reader = new FileReader();
          reader.onload = function (data) {
            document.getElementById("avatar-img").src = data.target.result;
            console.log(data.target.result);
            document.getElementById("avatar-img").onload = function () {
              // Upload the selected image automatically into the 'uploads' folder
              var filename = "avatar.jpg";
              var data = new FormData();
              data.append('file', document.getElementById('imageData').files[0]);
              var websitePath = "<?php echo $_GLOBALS['WEBSITE_PATH'] ?>";

              $.ajax({
                url : "upload-avatar.php",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function(data) {
                  console.log(websitePath + data);
                  // Set value in the input URLTxt
                  document.getElementById("avatarURLTxt").value = websitePath + data;                     
                }, error: function(e) { alert("Something went wrong, try again! " + e); }
              });
            };
          };

          if (document.getElementById('imageData').files[0]) {
            reader.readAsDataURL(document.getElementById('imageData').files[0]);
          }
        };            
        </script>
        

        <hr>


        <!-- Cover image -->
        <div class="text-center">
          <img id="cover-img" class="rounded img-fluid" src="<?php echo $cuCoverURL ?>" width="150">
          <br>
          
           <div class="btn btn-white">Select cover
            <input id="coverData" name="file" type="file" accept="image/*">
          </div>
          </div>

        <!-- AUTOMATICALLY UPLOAD SELECTED IMAGE -->
        <script>
        document.getElementById("coverData").onchange = function () {
          var reader = new FileReader();
          reader.onload = function (data) {
            document.getElementById("cover-img").src = data.target.result;
            console.log(data.target.result);
            document.getElementById("cover-img").onload = function () {
            // Upload the selected image automatically into the 'uploads' folder
            var filename = "cover.jpg";
            var data = new FormData();
            data.append('file', document.getElementById('coverData').files[0]);
            var websitePath = "<?php echo $_GLOBALS['WEBSITE_PATH'] ?>";

            $.ajax({
              url : "upload-cover.php",
              type: 'POST',
              data: data,
              contentType: false,
              processData: false,
              success: function(data) {
                console.log(websitePath + data);
                // Set value in the input URLTxt
                document.getElementById("coverURLTxt").value = websitePath + data;                     
              }, error: function(e) { alert("Something went wrong, try again! " + e); }
            });
          };
        };

        if (document.getElementById('coverData').files[0]) {
          reader.readAsDataURL(document.getElementById('coverData').files[0]);
        }
      };            
    </script>
    

        <!-- form -->
        <form class="contact-form" action="save-profile.php" target="myframe">
          <div class="row">
            
            <div class="col-md-12">
              <div class="form-group">
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-user-circle"></i></span>
                  <?php 
                    echo '<input type="text" class="form-control" placeholder="Username" name="username" value="'.$cuUsername.'">';
                  ?>
                </div>
              </div>
            </div><!-- ./ col -->

            <div class="col-md-12">
              <div class="form-group">
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-user-circle"></i></span>
                  <?php
                    echo '<input type="text" class="form-control" placeholder="Full name" name="fullName" value="'.$cuFullname.'">';
                  ?>
                </div>
              </div>
            </div><!-- ./ col -->

            <div class="col-md-12">
              <div class="form-group">
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-envelope"></i></span>
                  <?php
                    echo '<input type="email" class="form-control" placeholder="E-mail" name="email" value="'.$cuEmail.'">';
                  ?>
                </div>
              </div>
            </div><!-- ./ col -->

            <div class="col-md-12">
              <div class="form-group">
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-pencil"></i></span>
                  <?php 
                    echo '<textarea type="text" rows="2" class="form-control" placeholder="Something about you" name="aboutMe">'.$cuAboutMe.'</textarea>';
                  ?>
                </div>
              </div>
            </div><!-- ./ col -->
              
            <!-- hidden avatarURL input -->
            <input id="avatarURLTxt" class="form-control" style="display: none;" size="100" type="text" name="avatarURL" value="">
            
            <!-- hidden coverURL input -->
            <input id="coverURLTxt" style="display: none;" size="100" type="text" name="coverURL" value="">
          
          </div>

          <div class="row">
            <div class="col-md-4 ml-auto mr-auto text-center">
              <button type="submit" onclick="showLoadingForEditProfile()" class="btn btn-primary btn-raised btn-block">Update profile</button>
            </div>
          </div>
         
        </form><!-- ./ form -->

        <div class="row">
            <div class="col-md-4 ml-auto mr-auto text-center">
              <a href="account.php" class="btn btn-white btn-raised btn-block" style="margin-bottom: 50px;">Back to Account</a>
            </div>
        </div>

        <!-- Hidden frame to stay on this page -->                                
        <iframe name="myframe" style="display:none;"></iframe>


    </div><!-- ./ col -->
  </div><!-- ./ row -->

    </div><!-- ./ container -->
  </div><!-- ./ main-raised -->


  <!-- footer -->
  <?php include 'footer.php'; ?>


<!--  Javascript   -->

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


// SHOW LOADING MODAL (WHILE EDITING PROFILE)
function showLoadingForEditProfile() {
    // Show loading modal
    document.getElementById("loadingText").innerHTML = "Updating your profile...";
    $('#loadingModal').modal('show');
    
    setTimeout(function(){
        location.reload(); 
    }, 2500);
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