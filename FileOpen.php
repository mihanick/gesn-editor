<?php
    //if the filename was set in $_REQUEST
    if (isset($_REQUEST['filename']))   {
       $filename=$_REQUEST['filename'];
       
       if ($filename=="default.xml"||$filename==".xml")  
           //Should not save empty filename or overwrite default.xml
           echo "<span class='span-error'>Could not save with specified name</span>";
       else if (file_exists($filename))
            //If file exist we kinda warn
            echo "<span class='span-warning'>Owerwrite</span>";
           else 
            //Otherwise no reason not to allow saving   
            echo "<span class='span-good'>Create a new file</span>";
    };
?>
