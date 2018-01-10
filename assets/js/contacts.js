(function handleContact() {
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
})()


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
