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
    padId = document.getElementById("padId").getAttribute("value");
    console.log(`Pad ID: '${padId}' connecting to socket!`);

    socket.connect()

    // Now that you are connected, you can join channels with a topic:
    let channel = socket.channel(`sync:${padId}`, {})
    channel.join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp)
      })
      .receive("error", resp => {
        console.log("Unable to join", resp)
      })


    channel.on("change", (resp) => {
      console.log("Incoming change", resp);
      var editor = ace.edit("myEditor");
      let arr = new Array(resp.data);
      editor.getSession().getDocument().applyDeltas(arr);
    })

    ////////////////////////////////////////////////////////////////////////////
    // Setup editor.
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
          if (editor.curOp && editor.curOp.command.name) {
            console.log("Pushing change!")
            channel.push("change", delta);
          }
        })
      }
    );
  }
});

export default socket