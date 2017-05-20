initialization() ;

function files() {
     var results=$.ajax({
        type: "GET",
        url: "/files",
        async: false,
//        data: { },
//        success: load_receive
    });
    filenames= results.responseJSON.files;
    var olnode=document.getElementById("file_options");
    while (olnode.firstChild) {
        olnode.removeChild(olnode.firstChild);
    }
    var newopt=document.createElement("option");
    newopt.setAttribute("value","none");
    newopt.innerHTML = "None";
    newopt.selected=true;
    olnode.appendChild(newopt);
    for (var i = 0; i < filenames.length; ++i){
        var newopt=document.createElement("option");
        newopt.setAttribute("value",filenames[i]);
        newopt.innerHTML = filenames[i];
        olnode.appendChild(newopt);
    }
}

function handleFileSelect(what) {
    if(filenames && parseInt(what.selectedIndex)>0 ){
        $.ajax({
            type: "POST",
            url: "/load",
            async: true,
            data: {file:filenames[parseInt(what.selectedIndex)-1] },
            success: load_receive
        });
    }
}

function load_receive(response) {
    if(response.flag){
        display_num_labeled(response);
        $("button").removeAttr('disabled');
        train_send()
    }
    else{
        window.alert("Load file failed!!");
    }
}

function export_send(){
    $.ajax({
        type: "POST",
        url: "/export",
        async: true,
        data: {},
        success: export_receive
    });
}

function export_receive(response) {
    if(response.flag){
        window.alert("Export succeeded!!");
    }
    else{
        window.alert("Export failed!!");
    }
}

function initialization(){
    // global variables
    current_node=document.getElementById("elasticinput");    
    changed=false;
    learn_result={};
    $("#myImage").removeAttr("src")



}


function display_num_labeled(response){    
    document.getElementById("num_labeled").innerText="Documents Coded: "+response.pos.toString()+"/"+response.done.toString()+" ("+response.total.toString()+")";
}


function show_send(what,which) {
    $("ol li").css("color","white");
    $(what).css("color","yellow");
    current_node=what;
    document.getElementById("send_label").removeAttribute('disabled');
    var tmp={};
    if (which=="search"){
        tmp=search_result;        
    }
    else if (which=="learn"){
        tmp=learn_result.show;
    }
    else if (which=="train"){
        tmp=train_result;
    }

    document.getElementById("which_part").value=which;
    document.getElementById("display").labeling.value=tmp[what.value].code;
    document.getElementById("displaydoc_id").value = tmp[what.value].id;
    $("#truelabel").html("True Label: "+tmp[what.value].label);
    // document.getElementById("displaydoc").innerHTML = tmp[what.value]._source.selftext;
    $("#displaydoc").html("<h3><a href=\""+tmp[what.value]["pdf"]+"\" target=\"blank\">"+tmp[what.value]["title"]+"</a></h3>"+tmp[what.value]["abstract"]);
}


function labeling_send(what){
    $.ajax({
        type: "POST",
        url: "/labeling",
        async: true,
        data: { id: document.getElementById("displaydoc_id").value, label: what.labeling.value },
        success: labeling_receive
    });
}

function labeling_receive(response){
    
    if(response.flag){
        display_num_labeled(response);
    }  
    nextnode=current_node.nextSibling;
    prevnode=current_node.previousSibling;
    current_node.remove();
    if(nextnode){
        show_send(nextnode,document.getElementById("which_part").value);
    }
    else if(prevnode){
        show_send(prevnode,document.getElementById("which_part").value);
    }
    else{
        document.getElementById("displaydoc_id").value = "none";
        $("#displaydoc").html("Done! Hit Next Button for next batch.");
        document.getElementById("send_label").setAttribute("disabled","disabled");
    }  
}




function train_send(){
    changed=false;
    var olnode=document.getElementById("learn_result");
//    var ids=''
//    for (var i = 0; i < olnode.children.length; ++i){
//        ids=ids+learn_result.show[olnode.children[i].value]["id"]+',';
//    }
//    if (ids.length>0){
//        $.ajax({
//            type: "POST",
//            url: "/labelrest",
//            async: false,
//            data: { id: ids }
//        });
//    }
    for (var i = 0; i < olnode.children.length; ++i){
        $.ajax({
            type: "POST",
            url: "/labeling",
            async: false,
            data: { id: learn_result.show[olnode.children[i].value]["id"], label: "undetermined" }
        });
    }

    $.ajax({
        type: "POST",
        url: "/train",
        async: true,
        data: { },
        success: train_receive
    }); 
}

function train_receive(response){
    learn_result=response;
    var olnode=document.getElementById("learn_result");
    while (olnode.firstChild) {
        olnode.removeChild(olnode.firstChild);
    }

    for (var i = 0; i < learn_result.show.length; ++i){

        var newli=document.createElement("li");
        var node=document.createTextNode( learn_result.show[i]["title"]+" ("+learn_result.show[i]["score"].toString()+")");
        newli.appendChild(node);
        newli.setAttribute("value",i);
        newli.setAttribute("onclick","show_send(this,\"learn\")");
        olnode.appendChild(newli);
    }
    show_send(olnode.firstChild,"learn");
}



function restart_send(){
    if (confirm("You will loose all your effort so far, are you sure?") == true) {
        $.ajax({
            type: "POST",
            url: "/restart",
            async: true,
            data: {  },
            success: restart_receive
        });
        initialization();
    }    
}
function restart_receive(response){
    var olnode=document.getElementById("learn_result");
    while (olnode.firstChild) {
        olnode.removeChild(olnode.firstChild);
    }
    load_receive(response)
}

function check_response(response){
    if(response=="done"){
        window.alert("Done!");
        return true;
    }
}

function highlight(text, which){
    if (which=="search"){
        var keywords=stemmer(search_key.toLowerCase()).split(' ');
        var exp=/(\w+)/g;
        function searchhighlight(match){
            if(keywords.indexOf(stemmer(match.toLowerCase()))>-1){
                return "<span style='background-color: green'>"+match+"</span>";
            }
            else{
                return match;
            }
        }
        return text.replace(exp,searchhighlight);
    }
    else{
        var ind = [];
        for (var i = 0; i < voc.length; ++i){
            ind.push(i);
        }
        ind.sort(function (a,b) {return Math.abs(coef[b])-Math.abs(coef[a])});
        var redones=[];
        var greenones=[];
        for (var i=0; i< Math.min(display_limit, voc.length); ++i){
            if (coef[ind[i]]>0){
                greenones.push(voc[ind[i]]);
            }
            else if(coef[ind[i]]<0){
                redones.push(voc[ind[i]]);
            }
        }
        var exp=/(\w+)/g;
        function redorgreen(match){
            if(greenones.indexOf(stemmer(match.toLowerCase()))>-1){
                return "<span class='tooltip' style='background-color: green'>"+match+"<span class='tooltiptext'>"+coef[voc.indexOf(stemmer(match.toLowerCase()))]+"</span></span>";
            }
            else if(redones.indexOf(stemmer(match.toLowerCase()))>-1){
                return "<span class='tooltip' style='background-color: red'>"+match+"<span class='tooltiptext'>"+coef[voc.indexOf(stemmer(match.toLowerCase()))]+"</span></span>";
            }
            else{
                return match;
            }
        }
        
        return text.replace(exp,redorgreen);
    }    
}



