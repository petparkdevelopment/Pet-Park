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
<!-- loading modal -->
<div id="loadingModal" class="modal fade" tabindex="-1"  data-backdrop="static" data-keyboard="false" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-body">
        <div class="text-center">
          <h5><i class="fa fa-spin fa-spinner"></i><br><br>
            <p id="loadingText"> Loading...</p>
          </h5>
        </div>
      </div><!-- end modal body -->
</div></div></div><!-- ./ loading modal -->
        


<!-- footer -->
<footer class="footer ">
  <div class="container">
    <nav class="pull-left">
      <ul>
        <li><a href="faq.html">FAQ</a></li>
        <li><a href="tou.html">Terms of use</a></li>
      </ul>
    </nav>
    <div class="copyright pull-right">
      &copy; <script>document.write(new Date().getFullYear())</script>, made with <i class="fa fa-heart"></i> by <a href="http://bit.ly/2PdQZBp" target="_blank">cubycode.
    </div>
  </div><!-- ./ container -->  
</footer><!-- ./ footer -->

        

<!--  Javascript   -->
<script src="assets/js/core/jquery.min.js"></script>
<script src="assets/js/core/popper.min.js"></script>
<script src="assets/js/bootstrap-material-design.js"></script>

<!--  Plugin for Date Time Picker and Full Calendar Plugin  -->
<script src="assets/js/plugins/moment.min.js"></script>

<!--	Plugin for the Datepicker, full documentation here: https://github.com/Eonasdan/bootstrap-datetimepicker -->
<script src="assets/js/plugins/bootstrap-datetimepicker.min.js"></script>

<!--	Plugin for the Sliders, full documentation here: http://refreshless.com/nouislider/ -->
<script src="assets/js/plugins/nouislider.min.js"></script>

<!-- Material Kit Core initialisations of plugins and Bootstrap Material Design Library -->
<script src="assets/js/material-kit.js?v=2.0.0"></script>

<script src="assets/js/functions.js"></script>
';
?>