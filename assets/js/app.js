// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import PieChart from "./hooks/pie_chart";

let Hooks = {
    PieChart: PieChart
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
    hooks: Hooks
})

// ===== ADD FLASH FUNCTIONALITY HERE =====
// Flash message auto-dismiss with progress bar
let flashTimeouts = new Map();

// Handle flash mounted event
window.addEventListener("flash:mounted", (e) => {
    const flash = e.target;
    const progressBar = flash.querySelector('.progress-bar');

    if (progressBar) {
        // Force reflow to ensure animation starts
        progressBar.offsetHeight;

        // Start progress bar animation
        requestAnimationFrame(() => {
            progressBar.style.transition = 'width 5s linear';
            progressBar.style.width = '100%';
        });
    }

    // Set timeout to remove flash
    const timeoutId = setTimeout(() => {
        flash.style.transition = 'all 0.3s ease-in-out';
        flash.style.opacity = '0';
        flash.style.transform = 'translateX(100%) scale(0.95)';

        setTimeout(() => {
            if (flash.parentNode) {
                flash.parentNode.removeChild(flash);
            }
        }, 300);
    }, 5000);

    flashTimeouts.set(flash, timeoutId);
});

// Clear timeout when flash is manually closed
document.addEventListener('click', (e) => {
    const closeButton = e.target.closest('[role="alert"] button');
    if (closeButton) {
        const flash = e.target.closest('[role="alert"]');
        if (flash) {
            const timeoutId = flashTimeouts.get(flash);
            if (timeoutId) {
                clearTimeout(timeoutId);
                flashTimeouts.delete(flash);
            }
        }
    }
});

// Clean up on page navigation
document.addEventListener("phx:page-loading-start", () => {
    flashTimeouts.forEach((timeoutId, flash) => {
        clearTimeout(timeoutId);
        if (flash.parentNode) {
            flash.parentNode.removeChild(flash);
        }
    });
    flashTimeouts.clear();
});
// ===== END FLASH FUNCTIONALITY =====

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

