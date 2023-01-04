import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['tooltip'];

  connect = () => this.class = 'stationTooltip';

  show () {
    for (const tooltip of this.tooltipTargets) {
      // prevent more than one tooltip from being open at the same time, by first closing any previously opened tooltip
      let openTooltips = Array.from(document.querySelectorAll('.openTooltip'));
      if (openTooltips.length >= 1) {
        let abbr = openTooltips[0].dataset.abbr;
        let closeLink = document.getElementById(`close_${abbr}`);
        openTooltips[0].classList.add('hidden');
        closeLink.click();
      }
      tooltip.classList.remove('hidden');
      tooltip.classList.add('openTooltip');
    }
  }

  hide = () => this.tooltipTarget.classList.add('hidden');
}