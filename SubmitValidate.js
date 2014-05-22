    
function Validate_FileName(){
    //Function is binded to #file_save_path dynamic input to
    //check filesave path by means of ajax
    
    //get value and add .xml extension, serialize for request
    //(.xml extension added in code in order not-to-check case of extension xml or XML
    filepath="filename="+$(this).val()+".xml";
    
    //disabling control for the time of ajax request
    $(this).attr("disabled", "disabled");
    
    $.ajax({
        url: "FileOpen.php",
        type:"POST",
        cache: false,
        data: filepath,

        // callback handler that will be called on success
        success: function(html){
            //updating status
            $("#savestatus").html(html);
            //changing filename
            $("#filename").text($("#file_save_path").val()+".xml");
        },
        // callback handler that will be called on error
        error: function( textStatus, errorThrown){
            // log the error to the console
            console.log(
                "The following error occured: "+
                textStatus, errorThrown
            );
        },
        // callback handler that will be called on completion
        // which means, either on success or error
        complete: function(){
            //after all enabling file_save_path
            $("#file_save_path").removeAttr("disabled");
        }
    });    
}

function commit_edit() {
    
    //http://codething.ru/ajax.php
    //http://stackoverflow.com/questions/5004233/jquery-ajax-post-request-for-an-example
    
    $(".jobForm").submit(function(event){
        //anyway we will not only send data by this function
        //but also hide and set $filename if user hit Enter on savepath input#file_save_path
         
        // prevent default posting of form
        event.preventDefault(event);
        
        //-------------This code is for converting form data to xml-----------------
        //preparing xml data for sending to edit.php
        //http://jsfiddle.net/kBBz2/
        var sxml = "";
        function recurcive_job_find(){
            //The function runs through all form divs and textareas
            
            //@ids here are automatically-generated in xslt
            //@classes here could be 'job' 'Rate' 'RateTechnics' etc.
            sxml+="<div "+
                'id="'+$(this).attr('id')+'" '+
                'class="'+$(this).attr('class')+'"'+
                '>';
                //grab all div children divs recurcively
                $(this).children("div").each(recurcive_job_find);
                
                //grab textareas to xml-serialize their values
                $(this).children("textarea").each(function(key,val){
                   var jatt=$("<att>",{               //this will create jQuery <att>
                       name:$(val).attr("name"),      //with @name taken from textarea
                       text:$(val).val()              //and value from textarea value
                   });
                   //<xmlcontaier> is strpped, but we take it's inner html
                   //that is in fact just a string from jatt object
                   //should be smarter solution, but I don't know it
                   sxml+=$("<xmlcontainer>").append(jatt).html();
                });                    
            sxml+="</div>";   //closing current div
        }
        
        //running recursive search over div#ppr to 
        //convert form data to xml, that we'll pass to server
        $(".ppr").children().each(recurcive_job_find);
        
        //------------------------This code is for handling file save path----------------
        //find hidden div, that contains filename
        var filename = $("#filename").text();
        
        //removing span-for-saving (if there was any if user previously hit the button)
        $("#ask_for_save").remove();
        //if default or empty file was selected we will prompt user for filename
        if (filename=="default.xml"||filename==".xml"){
            //Dynamically create span-for-saving a.k.a 'var jsavepath' that contains input field .xml suffix
            //and span to display save status
            jsavepath=$("<span id='ask_for_save'><input type='text' id='file_save_path'/>.xml <span id='savestatus'></span></span>");
            //add default filename
            jsavepath.find("#file_save_path").attr("value", "files/ГЭСН/000");
            //Place span-for-saving after the send button
            $("#send").after(jsavepath);
            //focusing to the input field, binding Ajax validation function and triggering .keyup to first validate by default
            $("#file_save_path").focus().keyup(Validate_FileName).keyup();
        }else{
            //--------------------This code is for submitting form data---------------------
            //we assume here that filename is validated and 
            //Creating xml container to append root ppr node with filename
            jppr=$("<ppr>").attr("filename",filename);
            //appending form xml-data to container...
            jppr.html(sxml);
            //and converting it back to string <xmlcontainer> is needed because it stripped
            sxml=$("<xmlcontainer>").append(jppr).html();

            //DEBUG: debug output for request data
            $(".js-request").html(sxml);

            //http://stackoverflow.com/questions/5075778/how-do-i-modify-serialized-form-data-in-jquery
            // let's disable the inputs for the duration of the ajax request
            $(".jobForm").find("textarea").attr("disabled", "disabled");
            // fire off the request to /edit.php
            $.ajax({
                url: "edit.php",   //This is edit page
                type:"POST",
                cache: false,
                data: sxml,        //sxml is form data with container
                success: function(html){                    // callback handler that will be called on success
                    //DEBUG: Showing Ajax response in hidden div.test-edit-response
                    $(".test-edit-response").html(html);
                },
                error: function( textStatus, errorThrown){  // callback handler that will be called on error
                    console.log(                            // log the error to the console
                        "The following error occured: "+
                        textStatus, errorThrown
                    );
                },
                complete: function(){                       // callback handler that will be called on completion which means, either on success or error
                    // enable the inputs
                    $(".jobForm").find("textarea").removeAttr("disabled");
                }
            });        
        }
    }); 
}

    
$(document).ready(function(){
    //all we gotta do here is to handle submit
    commit_edit();
  //-------------------This code is for copying(adding) and removing divs------------------------
  //Creating links over div so that we can copy or remove divs
  //Links will appear on certain divs upon mouse hover
  $('div .job, .Rate, .RateTechnics, .RatePersonal, .RateMaterial').hover(function() {
      
    jpopupdiv=  $("<div>")               //create a div
                .addClass("pop-up")      //set popup class for it
                .append(
                                         //append a link [+] with a title to distiguish which node we're adding
                    $("<a class='a-copy' href='#'>[+]</a><br/>")
                        .attr("title","copy "+$(this).attr("class"))
                    )
                .append(                 //same for [-] link
                    $("<a class='a-remove' href='#'>[-]</a>")
                        .attr("title","remove "+$(this).attr("class"))
                    );
    //append div.pop-up to the jobs etc.                        
    $(this).append(jpopupdiv);
    
      //handling a-remove click
      $(".a-remove, .a-copy").click(function(event){
          //function(event) is requied to work in firefox
          //restricting jumping from links
        event.preventDefault();
        
        //find the parent div from the links
        //this is actually the div-to-action we want to copy or delete
        var parentDiv=$(this).
            closest('div .job, .Rate, .RateTechnics, .RatePersonal, .RateMaterial');
        
        if ($(this).attr("class")=="a-remove") //if [-] was hit
            //Get parent from div-to-action and 
            //try to find siblings of the same class as we want to delete
            //if the div-to-action is last , we won't allow deleting
            if (parentDiv.parent().children("."+parentDiv.attr("class")).length>1)
                parentDiv.remove();
        if ($(this).attr("class")=="a-copy")  //if [+] was hit
            //clone(true) to copy events and all the stuff
            parentDiv.clone(true).insertAfter(parentDiv);
      });
  }, function() {
    //when mouse is out - remove div.pop-up
    $('div.pop-up').remove();
  });

    //textarea autoexpand
    //TODO:

});
