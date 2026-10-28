import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tooltip'];

  connect = () => this.class = 'stationTooltip';

  show (event) {
    // Close any previously opened tooltip
    let openTooltips = Array.from(document.querySelectorAll('.openTooltip'));
    if (openTooltips.length >= 1) {
      let abbr = openTooltips[0].dataset.abbr;
      let closeLink = document.getElementById(`close_${abbr}`);
      openTooltips[0].classList.add('hidden');
      openTooltips[0].classList.remove('openTooltip');
      closeLink.click();
    }

    for (const tooltip of this.tooltipTargets) {
      tooltip.classList.remove('hidden');
      tooltip.classList.add('openTooltip');
      // Reset shift
      tooltip.style.setProperty('--tooltip-shift', '0px');
      tooltip.style.setProperty('--pointer-compensate', '0px');
      
      setTimeout(() => this.keepInView(tooltip), 0);
    }
  }

  hide = () => {
    this.tooltipTarget.classList.add('hidden');
    this.tooltipTarget.classList.remove('openTooltip');
  };

  // Keep tooltip box in viewport by translating it, but compensate pointer so it stays pointing at station
  keepInView(tooltip) {
    const padding = 100;
    const rect = tooltip.getBoundingClientRect();
    const viewportWidth = window.innerWidth;

    let shift = 0;

    if (rect.left < padding) {
      shift = padding - rect.left;
    } else if (rect.right > viewportWidth - padding) {
      shift = (viewportWidth - padding) - rect.right;
    }

    if (shift !== 0) {
      tooltip.style.setProperty('--tooltip-shift', `${shift}px`);
      // Compensate pointer position in the opposite direction so it stays pointing at station
      tooltip.style.setProperty('--pointer-compensate', `${-shift}px`);
    }
  }
}
