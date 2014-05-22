<?php
    //--------------------Code for handling $_POST opened filename------------------
    if (isset($_REQUEST["filename"])){         //If the file was not set, we'll use default
        $filename=$_REQUEST["filename"];
        if (!file_exists($filename)){          //When there's no such file, as specified in request, than... 
            echo "Trying to reach:".$filename.PHP_EOL;
            echo "Cannot load source file :("; //...display an opennerror
        };   
    }else                               
        $filename="default.xml";               //Otherwise just set default file to open

    
    //-----------------------------Code for opening files----------------------------------
    //Setting up a default dir for opening files
    $default_dir = "files/ГЭСН";

    function pathinfo_utf($path) {
        //This function is used because core php pathinfo fucntion doesnot support UTF-8
        //It's a blackbox. See details:
        //http://php.net/manual/ru/function.pathinfo.php

        if (strpos($path, '/') !== false) $basename = end(explode('/', $path)); 
        elseif (strpos($path, '\\') !== false) $basename = end(explode('\\', $path)); 
        else return false; 
        if (empty($basename)) return false; 

        $dirname = substr($path, 0, strlen($path) - strlen($basename) - 1); 

        if (strpos($basename, '.') !== false) 
        { 
          $extension = end(explode('.', $path)); 
          $filename = substr($basename, 0, strlen($basename) - strlen($extension) - 1); 
        } 
        else 
        { 
          $extension = ''; 
          $filename = $basename; 
        } 

        return array 
        ( 
          'dirname' => $dirname, 
          'basename' => $basename, 
          'extension' => $extension, 
          'filename' => $filename 
        ); 
    } ;

    function recursive_scandir($directory){
        //function to recurcively parse default_dir to find xml files
        //http://php.net/manual/en/function.glob.php

        $files = glob($directory."/*");             //get directory wildcard
        foreach ($files as $file){                  //iterate through all files and folders
            $arrpath=pathinfo_utf($file);           //get file data in utf
            $base_filename=  $arrpath['basename'];  //get filename to display

            if (is_file($file)){                    //if file is found 
                if ($arrpath['extension']=="xml"){  //if the file is *.xml (we want to omit opening files of different type)
                    //Create a <li> and a <a> for opening file
                    //here full-filename is an argument for index.php
                    echo "<li><a href='index.php?filename={$file}'>{$base_filename}</a></li>";
                }
            };
            if (is_dir($file)){                         //if directory is found
                echo $base_filename."<br/>";            //show directory name
                    echo "<ul class='file_open_dir'>";  //create an <ul> for a set of directory-file-links
                    recursive_scandir($file);           //fire-up this scan recursively for subfolders and sub-files
                    echo "</ul>";
            };
        };

    }
    
    //Create a div for opening files and fill it by using recurcive_scandir function
    echo "<div class='files'>";
        //Just for visual identification for opened file
        echo "<div class='FileHeader'>Загружен:</div>";
        //Writing opened filename to hidden div#filename to get it
        //into jscript so we can later pass it to save to disk in edit.php
        echo "<div class='filename' id='filename'>{$filename}</div>";
        
        echo "<div class='FileHeader'>Доступны:</div>";
        recursive_scandir($default_dir);
        echo "<div class='expandSplit'>...</div>";
    echo "</div>";

   
    //-----------------------Code for converting opened file and displaying form -------------------------------
    
    $xml = new DOMDocument;
    if ($xml->load($filename)){                 //Try to load the XML source
        $xsl=new DOMDocument;
        $xsl->load('InfopathToForm.xslt');      //Load the xslt to transform Infopath data to internal (assuming our xslt is well-formed)
        
        $proc = new XSLTProcessor;              // Configure the transformer
        $proc->importStyleSheet($xsl);          // Import xslt
        $data = new DOMDocument;
                                                //convert opened file to internal xml that is called $data
        $data = new SimpleXMLElement($proc->transformToXML($xml));
        
        //Create a form and a send button for it
        echo "<div class='container'><form class='jobForm'>";          //Create submit form and its 'Send' button
        echo   "<input type='submit' id='send' value='Сохранить'/>";
          parse_recursive($data);               //Recurcively iterate through xml $data to create input fields and structure of the #jobForm
        echo "</form></div>";
    } else{                                     //Assuming source loading problem and throwing an error
        echo "Could not parse ".$filename;
    };

    //Function to recursively parse  xml source taken from:
    //http://www.phpfreaks.com/tutorial/handling-xml-data
    function parse_recursive(SimpleXMLElement $element){
        $attributes = $element -> attributes();   // get all attributes
        $children   = $element -> children();     // get all children
        $tag        = $element -> getName();      // get name of the element
        
        if ($tag=="div"){                         //grab a <div>
            $uid="";
            if (isset($attributes["id"]))
                $uid    = "id='"   .$attributes["id"].   "'";    //find @id if it is set
            $uclass     = "class='".$attributes["class"]."'";    //find @class assuming it is always set
            
            //create a div for each div
            echo    "<div {$uclass} {$uid}>";
                //do the same recursively for children
                foreach     ($children as $child) parse_recursive ($child);
            echo    "</div>";
        };            
        if ($tag=="att"){                      //Grab an attribute
            $sName  = $element->attributes();  //We'll get all array of attribute as one, assuming there's only one attribute 'name'
            $sValue = trim((string) $element); //Truncate whitespace of attribute value

            //create input-textarea for attribute
            echo "<textarea id='att' name='{$sName}' title='{$sName}' >{$sValue}</textarea>";
        };
    };
    
    
    
?>
