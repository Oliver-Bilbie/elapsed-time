const websocketUrl = "ELAPSED_TIME_ENDPOINT";

let socket;
let calibratedElapsedSeconds = null;
let clientStartTime = null;

const output = document.getElementById("counter");
const resetTimeButton = document.getElementById("resetButton");

function formatElapsedTime(seconds) {
  const days = Math.floor(seconds / (24 * 3600));
  seconds %= 24 * 3600;
  const hours = Math.floor(seconds / 3600);
  seconds %= 3600;
  const minutes = Math.floor(seconds / 60);
  seconds = Math.floor(seconds % 60);

  return `${days}d ${hours}h ${minutes}m ${seconds}s`;
}

function updateElapsedTime() {
  if (calibratedElapsedSeconds !== null && clientStartTime !== null) {
    const now = Date.now();
    const elapsedSinceClientStart = (now - clientStartTime) / 1000;
    const totalElapsedSeconds =
      calibratedElapsedSeconds + elapsedSinceClientStart;
    output.textContent = formatElapsedTime(totalElapsedSeconds);
  }
}

function connectWebSocket() {
  socket = new WebSocket(websocketUrl);

  socket.onopen = () => {
    console.log("WebSocket connection opened.");
    output.textContent = "Loading...";
    socket.send(JSON.stringify({ action: "get_time" }));
  };

  socket.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data);

      if (data.timestamp && typeof data.elapsed_seconds === "number") {
        console.log("Received timestamp and elapsed time:", data);
        calibratedElapsedSeconds = data.elapsed_seconds;
        clientStartTime = Date.now();

        // Update the displayed elapsed time immediately
        updateElapsedTime();
        // Start real-time updates
        setInterval(updateElapsedTime, 1000);
      } else {
        console.warn("Unexpected WebSocket message:", data);
      }
    } catch (e) {
      console.error("Error parsing WebSocket message:", e);
    }
  };

  socket.onclose = () => {
    console.log("WebSocket connection closed. Reconnecting in 3 seconds...");
    output.textContent = "WebSocket connection closed. Reconnecting...";
    setTimeout(connectWebSocket, 3000);
  };

  socket.onerror = (error) => {
    console.error("WebSocket error:", error);
    output.textContent = "An error occurred with the WebSocket connection.";
  };
}

resetTimeButton.addEventListener("click", () => {
  if (socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify({ action: "reset_time" }));
    console.log("Sent reset_time action");
  } else {
    console.warn("WebSocket is not open. Reset time action not sent.");
  }
});

connectWebSocket();
