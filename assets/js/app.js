// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

// ? Tailwind additions
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
// import { Socket } from "phoenix"
// import socket from "./socket"
//

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topBar from "topbar"

import CreateConversationFormHooks from "./hooks/create_conversation_form_hooks";
import ConversationListHooks from './hooks/conversation_list_hooks';
import ConversationHooks from './hooks/conversation_hooks';


// Show progress bar on live navigation and form submits
topBar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topBar.show())
window.addEventListener("phx:page-loading-stop", info => topBar.hide())

let Hooks = { CreateConversationFormHooks, ConversationListHooks, ConversationHooks };

let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks });
liveSocket.connect()

import "phoenix_html"
Notification.requestPermission() // returns a Promise that we're not much interested in for now
