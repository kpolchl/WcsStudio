// Keeps keyboard focus inside a dialog and returns it to the trigger on close.
// Phoenix.FocusWrap already traps focus via sentinel elements; this adds an
// explicit first/last Tab wrap and restores focus to whatever was focused
// before the modal mounted.
const FOCUSABLE = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  '[tabindex]:not([tabindex="-1"])',
].join(", ");

const ModalFocus = {
  mounted() {
    // Runs before show_modal()/Phoenix.FocusWrap move focus into the dialog.
    this.returnFocus = document.activeElement;

    this.onKeydown = (event) => {
      if (event.key !== "Tab") return;

      const focusables = Array.from(this.el.querySelectorAll(FOCUSABLE)).filter(
        (el) => el.offsetParent !== null || el === document.activeElement
      );
      if (focusables.length === 0) return;

      const first = focusables[0];
      const last = focusables[focusables.length - 1];

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    };

    this.el.addEventListener("keydown", this.onKeydown);
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.onKeydown);

    const target = this.returnFocus;
    if (target && document.contains(target)) {
      requestAnimationFrame(() => target.focus());
    }
  },
};

export default ModalFocus;
