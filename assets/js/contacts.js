let showEmailBtn = document.getElementById("show-email");

if (showEmailBtn) {
    showEmailBtn.addEventListener("click", function(ev) {
        ev.preventDefault();

        let emailDiv = document.getElementById("job_email");
        let phoneDiv = document.getElementById("job_phone");
        let jobID  = emailDiv.getAttribute("data-job-id");

        getAjax(`/api/jobs/${jobID}/job_contacts`, function(data){ showEmail(data, emailDiv, phoneDiv); });

        showEmailBtn.style.display = "none"

    })

}


function getAjax(url, success) {
    var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState>3 && xhr.status==200) success(xhr.response);
    };
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.send();
    return xhr;
}


function showEmail(data, emailDiv, phoneDiv) {
    data = JSON.parse(data)

    const email = data.job_email.replace(/['"]+/g, '')
    emailDiv.innerHTML +=
        '<i class="mail icon"></i>' + `<a href="mailto:${email}">${email}</a>`

    if (data.phone !== null) {
        phoneDiv.innerHTML +=
            `<i class="call icon"></i></i> ${data.phone}`
    }
}
