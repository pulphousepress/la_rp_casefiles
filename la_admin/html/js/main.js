window.addEventListener("message", (event) => {
  if (event.data.action === "toggle") {
    document.getElementById("console").style.display = event.data.show ? "flex" : "none";
  }
});

function sendEvent(eventName) {
  fetch(`https://${GetParentResourceName()}/triggerEvent`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify({ event: eventName })
  });
}

function sendCommand() {
  const input = document.getElementById("cmdInput").value.trim();
  if (input.length > 0) {
    sendEvent("command:" + input);
    addLog("» " + input);
    document.getElementById("cmdInput").value = "";
  }
}

document.getElementById("runCmd").addEventListener("click", () => {
  sendCommand();
});

function addLog(msg) {
  const logBox = document.getElementById("logs");
  const line = document.createElement("div");
  line.textContent = "[" + new Date().toLocaleTimeString() + "] " + msg;
  logBox.appendChild(line);
  logBox.scrollTop = logBox.scrollHeight;
}
