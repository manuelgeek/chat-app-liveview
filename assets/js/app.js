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
// import { Socket } from "phoenix"
// import socket from "./socket"
//

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } });
liveSocket.connect()

import "phoenix_html"