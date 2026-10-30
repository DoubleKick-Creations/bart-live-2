import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  locate() {
    if (!navigator.geolocation) {
      this.showRedToast()
      return
    }
    navigator.geolocation.getCurrentPosition(
      (position) => this.onSuccess(position),
      () => this.onDenied()
    )
  }

  onSuccess(position) {
    const lat = position.coords.latitude
    const lng = position.coords.longitude
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(`/stations/closest_station?latitude=${lat}&longitude=${lng}`, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': token
      }
    }).then(response => response.text()).then(html => {
      // Insert turbo stream
      Turbo.renderStreamMessage(html)
      // Open tooltip for closest station after stream processed
      setTimeout(() => {
        const toast = document.querySelector('#toast-container [data-station-abbr]')
        if (toast) {
          const abbr = toast.dataset.stationAbbr
          const link = document.querySelector(`#station_${abbr} .stationLink`)
          if (link) link.click()
        }
      }, 100)
    })
  }

  onDenied() {
    this.showRedToast()
  }

  showRedToast() {
    const container = document.getElementById('toast-container')
    if (!container) return
    container.innerHTML = `
      <div class="toast-message toast-red">
        <span>Without your location, the closest station can't be found.</span>
        <button type="button" class="toast-close" onclick="this.closest('.toast-message').remove()">×</button>
      </div>`
    setTimeout(() => { container.innerHTML = '' }, 10000)
  }
}
