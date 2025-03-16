window.addEventListener('message', (event) => {
    const data = event.data;
    switch(data.action) {
        case "speak":
            if (data.active) {
                $(".circle-ripple").fadeIn();
                $(".voice-elipse-2").html('<i class="fa-solid fa-microphone"></i>');
            } else {
                $(".circle-ripple").fadeOut();
                $(".voice-elipse-2").html('<i class="fa-solid fa-microphone-slash"></i>');
            }
            break;
        case "voice":
            $(".voice-elipse").html(data.lvl);
            break;
    }
});


window.addEventListener('message', function(event) {
    if (event.data.action === "updateFuel") {
        let fuelHud = document.getElementById("fuel-hud");

        if (event.data.display) {
            document.getElementById("fuel-text").innerText = `${event.data.fuel}%`;
            fuelHud.style.display = "flex"; 
        } else {
            fuelHud.style.display = "none"; 
        }
    }
});


window.addEventListener('message', function(event) {
    if (event.data.type === 'updateHudData') {
        const data = event.data.data;


        if (data.name) {
            document.getElementById('playername').innerHTML = `<i class="fa-solid fa-user"></i> ${data.name}`;
        }
        if (data.cash !== undefined) {
            document.getElementById('cash').innerHTML = `<i class="fa-solid fa-money-bill"></i> ${data.cash}`;
        }
        if (data.bank !== undefined) {
            document.getElementById('bank').innerHTML = `<i class="fa-solid fa-building-columns"></i> ${data.bank}`;
        }
        if (data.job) {
            document.getElementById('meslek').innerHTML = `<i class="fa-solid fa-briefcase"></i> ${data.job}`;
        }
    }
});


function requestHudData() {
    fetch(`https://${GetParentResourceName()}/babun-hud-get-datas`, {
        method: 'POST',
        body: JSON.stringify({}),
    })
    .then(response => response.json())
    .then(data => {
        window.postMessage({
            type: 'updateHudData',
            data: data
        });
    });
}

window.onload = function() {
    requestHudData();
}



window.addEventListener("message", function(event) {
    if (event.data.action === "toggleHUD") {
        hudVisible = !hudVisible;

        const hudElements = [
            "server-info",
            "playername-info",
            "cash-info",
            "bank-info",
            "meslek-info",
            "player-location",
            "player-id",
            "logo",
            "stat-info",
            "status-hud",
            "geardisplay"
        ];

        hudElements.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                element.style.display = hudVisible ? "block" : "none";
            }
        });

        const logo = document.querySelector(".logo");
        if (logo) {
            logo.style.display = hudVisible ? "block" : "none";
        }
    }
});


let hudVisible = false; 

window.addEventListener("message", function(event) {
    if (event.data.action === "showHUD") {
        hudVisible = true;
    } else if (event.data.action === "hideHUD") {
        hudVisible = false;
    }

    const hudElements = [
        "server-info",
        "playername-info",
        "cash-info",
        "bank-info",
        "meslek-info",
        "player-location",
        "player-id",
        "logo",
        "stat-info",
        "status-hud",
        "geardisplay"
    ];

    hudElements.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.style.display = hudVisible ? "block" : "none";
        }
    });

    const logo = document.querySelector(".logo");
    if (logo) {
        logo.style.display = hudVisible ? "block" : "none";
    }
});
