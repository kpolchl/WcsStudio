// Marks the nav link matching the current URL with aria-current="page".
// Works for both controller-rendered pages and LiveView navigation.
const NavActive = {
  mounted() {
    this.update = this.update.bind(this);
    this.update();

    window.addEventListener("phx:page-loading-stop", this.update);
    window.addEventListener("popstate", this.update);
  },

  destroyed() {
    window.removeEventListener("phx:page-loading-stop", this.update);
    window.removeEventListener("popstate", this.update);
  },

  update() {
    const path = window.location.pathname;

    document.querySelectorAll("[data-nav-path]").forEach((link) => {
      const navPath = link.dataset.navPath;
      const isActive = path === navPath || path.startsWith(`${navPath}/`);

      if (isActive) {
        link.setAttribute("aria-current", "page");
      } else {
        link.removeAttribute("aria-current");
      }
    });
  },
};

export default NavActive;
