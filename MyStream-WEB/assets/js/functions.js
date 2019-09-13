
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

// REPORT STREAM -------------------------------                    
function reportStream(sObjID, sRow) {  
  // Show loading modal
  document.getElementById('loadingText').innerHTML = " Reporting Stream...";
  $('#loadingModal').modal('show'); 

  $.ajax({
    url:"report-stream.php?sObjID=" + sObjID,  
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

// REPORT USER -------------------------------                    
function reportUser(userID, sRow) {  
  // Show loading modal
  document.getElementById('loadingText').innerHTML = " Reporting User...";
  $('#loadingModal').modal('show'); 

  $.ajax({
    url:"report-user.php?userID=" + userID,  
    type: "GET", 
    success:function(data) {
    var results = data.replace(/\s+/, ""); //remove any white spaces from the returned string    
    console.log(data);

    // Hide loadingModal
    $('#loadingModal').modal('hide'); 

    // Reload page
    setTimeout(function(){
      location.reload(); 
    }, 500);

  }});
}

// REPORT COMMENT -------------------------------                    
function reportComment(cObjID, sRow) {  
  // Show loading modal
  document.getElementById('loadingText').innerHTML = " Reporting Comment...";
  $('#loadingModal').modal('show'); 

  $.ajax({
    url:"report-comment.php?cObjID=" + cObjID,  
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


// FOLLOW/UNFOLLOW A USER -------------------------------                    
function followUser(uObjID, following) {  
  // Show loading modal
  document.getElementById('loadingText').innerHTML = " Please wait...";
  $('#loadingModal').modal('show'); 

  $.ajax({
    url:"follow-user.php?uObjID=" + uObjID + "&following=" + following,  
    type: "GET", 
    success:function(data) {
    var results = data.replace(/\s+/, ""); //remove any white spaces from the returned string    
    console.log(data);

    // FOLLOW
    if (results == "FOLLOW") {
      $( "#followButton").removeClass( "btn-white" ).addClass( "btn-primary" );
      document.getElementById('followButton').style.color = "#fff";
      document.getElementById('followButton').innerHTML = 'Following';
      
    // UNFOLLOW
    } else if (results == "UNFOLLOW") {
      $( "#followButton").removeClass( "btn-primary" ).addClass( "btn-white" );
      document.getElementById('followButton').style.color = "#000";
      document.getElementById('followButton').innerHTML = 'Follow';
    }

    // Reload page
    setTimeout(function(){
      $('#loadingModal').modal('hide'); 
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

function showLoadingModalReloadPage() {
  $('#loadingModal').modal('show');
  
  setTimeout(function(){
      location.reload(); 
  }, 500);      
}


// LOGOUT -----------------------------------
function logOut() {
  // Show Loading modal
  document.getElementById("loadingText").innerHTML = "Logging out, please wait...";
  $('#loadingModal').modal('show');
  
  $.ajax({
    url:"logout.php",  
    success:function(data) {
      var results = data;  
      console.debug(results);
      window.location.href = "login.php";
    // error
    }, error: function () { alert('Something went wrong. Try again!'); }
  });
}

