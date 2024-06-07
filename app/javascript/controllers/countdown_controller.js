import { Controller } from "@hotwired/stimulus";

const SECONDS_IN_A_MINUTE = 60;
const SECONDS_IN_AN_HOUR = 3600;
const SECONDS_IN_A_DAY = 86400;
const SECONDS_IN_A_MONTH = 2629743; // Average seconds in a month (30.44 days)
const SECONDS_IN_A_YEAR = 31556926; // Average seconds in a year (365.24 days)

// Connects to data-controller="countdown"
export default class extends Controller {
  static values = { timeLeft: Number };
  static targets = [
    "summary",
    "ticker",
    "years",
    "months",
    "days",
    "hours",
    "minutes",
    "seconds",
  ];

  connect() {
    this.#update();
    this.#startTicker();
  }

  disconnect() {
    this.#stopTicker();
  }

  #startTicker() {
    this.tickerInterval = setInterval(() => {
      this.timeLeftValue -= 1;
      this.#update();
    }, 1000);
  }

  #stopTicker() {
    clearInterval(this.tickerInterval);
  }

  #update() {
    const duration = this.duration;

    this.summaryTarget.textContent = this.#summaryContent(duration);

    this.yearsTarget.textContent = duration.years;
    this.monthsTarget.textContent = duration.months;
    this.daysTarget.textContent = duration.days;
    this.hoursTarget.textContent = duration.hours;
    this.minutesTarget.textContent = duration.minutes;
    this.secondsTarget.textContent = duration.seconds;
  }

  #summaryContent(duration = this.duration) {
    const result = Object.assign({}, duration);

    // Remove leading units that are 0
    for (const property in result) {
      if (result[property] === 0) {
        delete result[property];
      } else {
        break;
      }
    }

    return Object.keys(duration)
      .slice(0, 2)
      .map((key) => `${duration[key]} ${key}`)
      .join(" and ");
  }

  get duration() {
    let timeLeft = this.timeLeftValue;

    const years = Math.floor(timeLeft / SECONDS_IN_A_YEAR);
    timeLeft %= SECONDS_IN_A_YEAR;

    const months = Math.floor(timeLeft / SECONDS_IN_A_MONTH);
    timeLeft %= SECONDS_IN_A_MONTH;

    const days = Math.floor(timeLeft / SECONDS_IN_A_DAY);
    timeLeft %= SECONDS_IN_A_DAY;

    const hours = Math.floor(timeLeft / SECONDS_IN_AN_HOUR);
    timeLeft %= SECONDS_IN_AN_HOUR;

    const minutes = Math.floor(timeLeft / SECONDS_IN_A_MINUTE);

    const seconds = Math.floor(timeLeft % SECONDS_IN_A_MINUTE);

    return { years, months, days, hours, minutes, seconds };
  }
}
