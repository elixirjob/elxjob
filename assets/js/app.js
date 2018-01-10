// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


let showEmailBtn = document.getElementById("show-email");

if (showEmailBtn) {
    showEmailBtn.addEventListener("click", function(ev) {
        ev.preventDefault();

        let jobDiv = document.getElementById("job_email");
        let jobID  = jobDiv.getAttribute("data-job-id");

        getAjax(`/api/jobs/${jobID}/job_email`, function(data){ showEmail(data, jobDiv); });

        showEmailBtn.style.display = "none"

    })

}


function getAjax(url, success) {
    var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState>3 && xhr.status==200) success(xhr.responseText);
    };
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.send();
    return xhr;
}


function showEmail(email, div) {
    email = email.replace(/['"]+/g, '')
    div.innerHTML +=
        '<i class="mail icon"></i>' + `<a href="mailto:${email}">${email}</a>`
}
