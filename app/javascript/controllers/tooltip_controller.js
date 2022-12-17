import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['tooltip'];

  connect () {
    this.class = 'stationTooltip'
  }

  show () {
    this.tooltipTargets.forEach(async tooltip => {
      let openTooltips = Array.from(document.querySelectorAll('.openTooltip'));
      if (openTooltips.length >= 1) {
        let abbr = openTooltips[0].dataset.abbr;
        // probably don't need to async fetch remove, just don't open another tooltip and show warning, or add overlay with href of remove url so it acts more like a modal
        let url = `${window.location.href}stations/${abbr}/remove`
        console.log(`${url}`)
        let response = await fetch(url);
        console.log(response)
      } else {
        tooltip.classList.remove('hidden');
        tooltip.classList.add('openTooltip');
      }
    })
  }

  hide() {
    this.tooltipTargets.forEach(tooltip => {
      tooltip.classList.add("hidden");
    })
  }

  toggle() {
    this.tooltipTargets.forEach(tooltip => {
      tooltip.classList.toggle("hidden");
    })
  }
}

