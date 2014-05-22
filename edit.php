<?php
    
    //Forming correct xml string to create a DOMDocument
    //It should have standard xml header and only one root node
    //Root node <ppr> is formed in jscript on index.php
    $xmlstring='<?xml version="1.0" encoding="UTF-8"?>' . "\n" . 
        file_get_contents("php://input");
    
    //DEBUG: Dump request data to disk
    //file_put_contents("Request_dump.xml", $xmlstring);
    
    //DEBUG: echo xml data obtained from direct input
    echo "Debug: New form xml data <div>".$xmlstring."</div>".PHP_EOL;
      
    $xml = new DOMDocument('1.0', 'UTF-8');
    
    if ($xml->loadXML($xmlstring)){                      //Trying to load xml from the input
        
        $FormToInfopath=new DomDocument('1.0', 'UTF-8'); //Creating xslt processor
        $FormToInfopath->load("FormToInfopath.xslt");    //Loading xslt template to encode xml form data to infopath
        $proc = new XSLTProcessor();                     //Configure the xslt-processor
        $proc->importStyleSheet($FormToInfopath);        //Import xslt stylesheet into processor
        
        //Extracting filename from xml data in <ppr @filename> (dunno the sintax. googled for 'DOMNode get attributes'
        $filename=$xml->getElementsByTagName("ppr")->item(0)->
                attributes->getNamedItem("filename")->value;
        
        //DEBUG: Debug output of filename 
        echo "Debug: filename to save:{$filename};";
        
        //trainsforming form xml data to infopath
        $sTransformedString=$proc->transformToXML($xml);
        
        //Saving data to disk
        if (!empty($filename))   //check filename
            file_put_contents($filename, $sTransformedString);
        else                     //if filename was not found display error
            echo "ERROR: Cannot save file to disk. Path is empty".PHP_EOL;
        
        //DEBUG: Parsing and showing debug aoutput for transformed data
        //Parsing is not required, but it kinda proves that we saved valid xml
        $data = new DOMDocument('1.0', 'UTF-8');
        $data->loadXML($sTransformedString);
        echo "Debug: TransformedData:<div>".$data->saveXML()."</div>".PHP_EOL;
    } else {
        echo "ERROR: could not parse xml input";
    };
    
?>
