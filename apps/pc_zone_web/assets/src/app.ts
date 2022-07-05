import './fonts.css'

import 'phoenix_html'
import topbar from 'topbar'
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'

declare global {
  interface Window {
    liveSocket: any
    source_products: { id: string; name: string; other_names: string[] }[]
  }
}
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  ?.getAttribute('content')

let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {},
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })

window.addEventListener('phx:page-loading-start', (info: any) => {
  console.log(info.detail.kind)
  if (info.detail.kind !== 'error') {
    topbar.show()
  } else {
    console.log(info.detail)
  }
})

window.addEventListener('phx:page-loading-stop', (info: any) => {
  topbar.hide()
})

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
