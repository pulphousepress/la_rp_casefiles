window.addEventListener("message", function(event) {
    const data = event.data;
    if (data.action === "toggle") {
        document.getElementById("weatherBox").className = data.show ? "" : "hidden";
    }
    if (data.action === "updateWeather") {
        document.getElementById("zone").textContent = data.zone;
        document.getElementById("weather").textContent = data.weather;
        if (data.clock) {
            document.getElementById("clock").textContent = data.clock;
        }
    }
});
