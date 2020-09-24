import {
  Socket
} from "phoenix"

let socket = new Socket("/socket", {
  params: {
      token: window.userToken
  }
})

document.addEventListener("DOMContentLoaded", function(event) {
  var element = document.getElementById("myEditor");
  //If it isn't "undefined" and it isn't "null", then it exists.
  if (typeof(element) != 'undefined' && element != null) {
      ////////////////////////////////////////////////////////////////////////////
      // Setup socket
      var padId = document.getElementById("padId").getAttribute("value");
      let channel = socket.channel(`sync:${padId}`, {})

      ////////////////////////////////////////////////////////////////////////////
      // Setup editor.
      var socket_change = false;
      YUI().use(
          'aui-ace-editor',
          function(Y) {
              var editor = new Y.AceEditor({
                  boundingBox: '#myEditor',
                  mode: 'scheme',
              }).render();

              var editor = ace.edit("myEditor");
              editor.setTheme("ace/theme/chaos");
              editor.setShowPrintMargin(false);

              editor.session.on('change', function(delta) {
                  console.log("Change callback triggered! From socket: ", socket_change)
                  if (socket_change) {

                  } else {
                      channel.push("change", delta);
                      channel.push("state", editor.getValue())
                  }
              })

              //////////////////////////////////////////////////////////////////
              // Connect to server.
              socket.connect()
              channel.join()
                  .receive("error", resp => {
                      console.log("Unable to connect to channel.", resp)
                  })

              //////////////////////////////////////////////////////////////////
              // Event handlers

              // Local change.
              channel.on("change", (resp) => {
                  socket_change = true;
                  var editor = ace.edit("myEditor");
                  let arr = new Array(resp.data);
                  editor.getSession().getDocument().applyDeltas(arr);
                  socket_change = false;
              })

              // Initial text content.
              channel.on("init", (resp) => {
                  socket_change = true;
                  var editor = ace.edit("myEditor");
                  editor.setValue(resp.state);
                  editor.clearSelection();
                  socket_change = false;
              });
          });
  }
});

export default socket