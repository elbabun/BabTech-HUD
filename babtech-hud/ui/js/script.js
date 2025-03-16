window.addEventListener('message', function(event) {
    if (event.data.type === 'updateStatusHud') {
        if (event.data.show) {
            document.getElementById('status-hud').style.display = 'block';

            const locationElement = document.getElementById('player-location');
            if (event.data.showLocation) {
                locationElement.style.display = 'block';
                document.querySelector('.location-value').textContent = event.data.location || 'Unknown Location';
            } else {
                locationElement.style.display = 'none';
            }

            updateBar('health', Math.min(100, Math.floor(event.data.health)));
            updateBar('armor', Math.min(100, Math.floor(event.data.armor)));
            updateBar('food', Math.min(100, Math.floor(event.data.food)));
            updateBar('water', Math.min(100, Math.floor(event.data.water)));

            const oxyBar = document.querySelector('.stat-bar.oxy');
            if (event.data.oxy > 0) {
                oxyBar.style.display = 'block';
                updateBar('oxy', Math.min(100, Math.floor(event.data.oxy)));
            } else {
                oxyBar.style.display = 'none';
            }
        }
    }
});


function updateBar(stat, value) {
    const bar = document.querySelector(`.stat-bar.${stat}`);
    if (bar) {
        bar.style.width = `${value}%`;
    }
}


function updateBar(type, value) {
    const bar = document.querySelector('.' + type + ' .bar-fill');
    const valueElement = document.querySelector('.' + type + ' .value');
    if (bar && valueElement) {
        value = Math.floor(value);
        bar.style.width = value + '%';
        valueElement.textContent = value + '%';
    }
}



function updateHUD() {
    updatePending = false;
    Object.entries(pendingUpdates).forEach(([type, value]) => {
        if (value !== lastValues[type]) {
            const element = hudElements[type];
            if (element) {
                element.bar.style.width = `${value}%`;
                element.value.textContent = `${value}%`;
                lastValues[type] = value;
            }
        }
    });
}

function updateBar(type, value) {
    const bar = document.querySelector('.' + type + ' .bar-fill');
    const valueElement = document.querySelector('.' + type + ' .value');
    if (bar && valueElement) {
        value = Math.floor(value);
        bar.style.width = value + '%';
        valueElement.textContent = value + '%';
    }
}

function onVehicleEnter() {
    document.body.classList.add('vehicle-entered');
}

function onVehicleExit() {
    document.body.classList.remove('vehicle-entered');
}

window.addEventListener('message', (event) => {
    if (event.data.action === 'setVehicleState') {
        if (event.data.inVehicle) {
            document.body.classList.add('vehicle-entered');
        } else {
            document.body.classList.remove('vehicle-entered');
        }
    }
});


