const Carousel = {
  mounted() {
    this.carousel = this.el.querySelector("#carousel");
    this.slides = this.carousel.children;
    this.indicators = this.el.querySelectorAll(".carousel-indicator");
    this.index = 0;

    this.update = () => {
      this.carousel.style.transform = `translateX(-${this.index * 100}%)`;
      this.indicators.forEach((el, i) => {
        el.classList.toggle("bg-white", i === this.index);
        el.classList.toggle("bg-white/50", i !== this.index);
      });
    };
    const go = (i) => {
      this.index = (i + this.slides.length) % this.slides.length;
      this.update();
    };

    this.el
      .querySelector("#next")
      .addEventListener("click", () => go(this.index + 1));
    this.el
      .querySelector("#prev")
      .addEventListener("click", () => go(this.index - 1));
    this.indicators.forEach((el, i) =>
      el.addEventListener("click", () => go(i)),
    );

    this.timer = setInterval(() => go(this.index + 1), 7000);
    this.update();
  },
  destroyed() {
    clearInterval(this.timer);
  },
};
export default Carousel;
