import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['tooltip'];

  connect () {
    this.class = 'stationTooltip'
  }

  show () {
    this.tooltipTargets.forEach(tooltip => {
      let openTooltips = Array.from(document.querySelectorAll('.openTooltip'));
      // prevent more than one tooltip from being opened at the same time, adjust this number to allow more than one
      if (openTooltips.length >= 1) {
        let abbr = openTooltips[0].dataset.abbr;
        let openTooltip = document.getElementById(`tooltip_${abbr}`);
        openTooltip.classList.add('hidden')
        openTooltip.classList.remove('openTooltip');
      }
      tooltip.classList.remove('hidden');
      tooltip.classList.add('openTooltip');
    })
  }

  hide() {
    this.tooltipTargets.forEach(tooltip => {
      tooltip.classList.add('hidden');
      tooltip.classList.remove('openTooltip');
    })
  }

}

