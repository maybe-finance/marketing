import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "answer", "icon"]

  connect() {
    // Show first FAQ by default
    if (this.questionTargets.length > 0) {
      this.questionTargets[0].setAttribute('aria-expanded', 'true')
      this.iconTargets[0].classList.remove('rotate-45')
      this.showAnswer(this.answerTargets[0])
    }
  }

  toggle(event) {
    const question = event.currentTarget
    const index = this.questionTargets.indexOf(question)
    const answer = this.answerTargets[index]
    const icon = this.iconTargets[index]
    const isExpanded = question.getAttribute('aria-expanded') === 'true'

    question.setAttribute('aria-expanded', !isExpanded)

    if (isExpanded) {
      this.hideAnswer(answer)
      icon.classList.add('rotate-45')
    } else {
      this.showAnswer(answer)
      icon.classList.remove('rotate-45')
    }
  }

  showAnswer(answer) {
    answer.classList.remove('hidden')
    answer.style.height = '0'
    answer.style.height = answer.scrollHeight + 'px'
  }

  hideAnswer(answer) {
    answer.style.height = answer.scrollHeight + 'px'
    // Force a reflow
    answer.offsetHeight
    answer.style.height = '0'

    answer.addEventListener('transitionend', () => {
      if (answer.style.height === '0px') {
        answer.classList.add('hidden')
      }
    }, { once: true })
  }
}
