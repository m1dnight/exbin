let hooks = {}
hooks.StatusHooks = {
    disconnected() {
        document.getElementById("connected").style.display = "none";
        document.getElementById("disconnected").style.display = "unset";
        console.log("disconnected")
    },
    reconnected() {
        document.getElementById("connected").style.display = "unset";
        document.getElementById("disconnected").style.display = "none";
        console.log("reconnected")
    },
    mounted() {
        document.getElementById("connected").style.display = "unset";
        document.getElementById("disconnected").style.display = "none";
        console.log("connected")
    }
}

import LiveSocket from "phoenix_live_view"
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: hooks })
liveSocket.connect()
window.liveSocket = liveSocket