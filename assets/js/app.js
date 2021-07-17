// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//

// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
import { Socket } from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

// Highlight.js 
const hljs = require("highlight.js");
window.hljs = hljs;
hljs.highlightAll();

// Linenumbers for code.
require('highlightjs-line-numbers.js');
hljs.initLineNumbersOnLoad();

import { Iconify } from "@iconify/iconify";
// import "bookmark_lines.js"
require("./bookmark_lines.js")


// This is for chart.js 3, but it doesn't give charts of the same height, for some reason.
import { Chart } from "chart.js/dist/chart.js";
// import {Chart} from "chart.js/dist/Chart.bundle.js";

require("./statistics.js");



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
