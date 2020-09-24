import {
  Socket
} from "phoenix"

let socket = new Socket("/socket", {
  params: {
    token: window.userToken
  }
})



document.addEventListener("DOMContentLoaded", function (event) {

  var element = document.getElementById("myEditor");
  //If it isn't "undefined" and it isn't "null", then it exists.
  if (typeof (element) != 'undefined' && element != null) {
    ////////////////////////////////////////////////////////////////////////////
    // Setup socket
    var padId = document.getElementById("padId").getAttribute("value");


    let channel = socket.channel(`sync:${padId}`, {})



    ////////////////////////////////////////////////////////////////////////////
    // Setup editor.
    var socket_change = false;
    YUI().use(
      'aui-ace-editor',
      function (Y) {
        var editor = new Y.AceEditor({
          boundingBox: '#myEditor',
          mode: 'scheme',
        }).render();

        var editor = ace.edit("myEditor");
        editor.setTheme("ace/theme/chaos");
        editor.setShowPrintMargin(false);

        editor.session.on('change', function (delta) {
          console.log("Change callback triggered! From socket: ", socket_change)
          if (socket_change) {

          }
          else {
            channel.push("change", delta);
            channel.push("state", editor.getValue())
          }
        })

        // Join the channel here, otherwise we might join and get state before the editor is loaded.
        socket.connect()

        channel.join()
          .receive("error", resp => {
            console.log("Unable to connect to channel.", resp)
          })

        channel.on("add_some_text", (resp) => {
          socket_change = true;
          var editor = ace.edit("myEditor");
          var value = editor.getValue() + ".";
          editor.setValue(value)
          editor.clearSelection();
          socket_change = false;
        })

        channel.on("change", (resp) => {
          socket_change = true;
          var editor = ace.edit("myEditor");
          let arr = new Array(resp.data);
          editor.getSession().getDocument().applyDeltas(arr);
          socket_change = false;
        })

        channel.on("init", (resp) => {
          console.log("Incoming init", resp);

          socket_change = true;
          var editor = ace.edit("myEditor");
          editor.setValue(resp.state);
        })


      }
    );




  }
});

export default socket