import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static classes = ["active"];
  static targets = ["option", "input", "list", "hiddenInput"];
  static values = { selected: String, count: Number, list: Array, customFilter: String };

  initialize() {
    this.show = false;
    this.countValue = this.countValue || 1;

    const selectedElement = this.optionTargets.find(
      (option) => option.dataset.value === this.selectedValue
    );
    if (selectedElement) {
      this.updateAriaAttributesAndClasses(selectedElement);
      this.syncInputWithSelected();
    }
  }

  connect() {
    this.syncInputWithSelected();
    this.element.addEventListener("keydown", this.handleKeydown);
    document.addEventListener("click", this.handleOutsideClick, true); // Use capture phase
    this.element.addEventListener("turbo:load", this.handleTurboLoad);
    this.inputTarget.addEventListener("input", this.filterOptions.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown);
    document.removeEventListener("click", this.handleOutsideClick, true); // Use capture phase
    this.element.removeEventListener("turbo:load", this.handleTurboLoad);
  }

  resetInput() {
    this.inputTarget.value = '';
    this.hiddenInputTarget.value = '';
    this.close();
  }

  selectedValueChanged() {
    this.syncInputWithSelected();
  }

  handleOutsideClick = (event) => {
    if (this.show && !this.element.contains(event.target) && !this.listTarget.contains(event.target)) {
      this.resetInput();
    }
  };

  handleTurboLoad = () => {
    this.close();
    this.syncInputWithSelected();
  };

  handleKeydown = (event) => {
    switch (event.key) {
      case " ":
      case "Enter":
        event.preventDefault();
        this.selectOption(event);
        break;
      case "ArrowDown":
        event.preventDefault();
        this.focusNextOption();
        break;
      case "ArrowUp":
        event.preventDefault();
        this.focusPreviousOption();
        break;
      case "Escape":
        this.close();
        break;
      case "Tab":
        this.close();
        break;
    }
  };

  focusNextOption() {
    this.focusOptionInDirection(1);
  }

  focusPreviousOption() {
    this.focusOptionInDirection(-1);
  }

  focusOptionInDirection(direction) {
    const currentFocusedIndex = this.optionTargets.findIndex(
      (option) => option === document.activeElement
    );
    const optionsCount = this.optionTargets.length;
    const nextIndex =
      (currentFocusedIndex + direction + optionsCount) % optionsCount;
    this.optionTargets[nextIndex].focus();
  }

  toggleList = () => {
    this.show = !this.show;
    this.listTarget.classList.toggle("hidden", !this.show);

    if (this.show) {
      this.filterInputTarget.focus();
    }
  };

  close() {
    this.show = false;
    this.listTarget.classList.add("hidden");
  }

  selectOption(event) {
    const selectedOption =
      event.type === "keydown" ? document.activeElement : event.currentTarget;
    this.updateAriaAttributesAndClasses(selectedOption);
    if (this.inputTarget.value !== selectedOption.getAttribute("data-value")) {
      this.updateInputValueAndEmitEvent(selectedOption);
    }
    this.inputTarget.value = selectedOption.textContent.trim();
    this.hiddenInputTarget.value = selectedOption.getAttribute("data-value");
    this.close();
    event.stopPropagation();
  }

  updateAriaAttributesAndClasses(selectedOption) {
    this.optionTargets.forEach((option) => {
      option.setAttribute("aria-selected", "false");
      option.setAttribute("tabindex", "-1");
      option.classList.remove(...this.activeClasses);
    });
    selectedOption.classList.add(...this.activeClasses);
    selectedOption.setAttribute("aria-selected", "true");
    selectedOption.focus();
  }

  updateInputValueAndEmitEvent(selectedOption) {
    const selectedValue = selectedOption.getAttribute("data-value");
    this.inputTarget.value = selectedValue;
    this.syncInputWithSelected();

    const inputEvent = new Event("input", {
      bubbles: true,
      cancelable: true,
    });
    this.inputTarget.dispatchEvent(inputEvent);
  }

  syncInputWithSelected() {
    const matchingOption = this.optionTargets.find(
      (option) => option.getAttribute("data-value") === this.inputTarget.value
    );
    if (matchingOption) {
      this.inputTarget.value = matchingOption.textContent.trim();
    }
  }

  filterOptions(event) {
    const filterValue = event.target.value.toLowerCase();
    this.listTarget.innerHTML = '';

    if (filterValue === '') {
      this.close();
      return;
    }

    const dataList = this.listValue
    let filteredList;

    if (this.hasCustomFilterValue && typeof window[this.customFilterValue] === 'function') {
      filteredList = window[this.customFilterValue](dataList, filterValue).slice(0, 5);
    } else {
      filteredList = dataList
        .filter(item =>
          item.name.toLowerCase().includes(filterValue) ||
          item.value.toLowerCase().includes(filterValue)
        )
        .slice(0, 5);
    }


    if (filteredList.length > 0) {
      filteredList.forEach(item => {
        const li = document.createElement('li');
        li.tabIndex = 0;
        li.dataset.searchSelectTarget = 'option';
        li.dataset.action = 'click->search-select#selectOption';
        li.dataset.value = item.value;
        li.className = 'flex items-center justify-start w-full px-2 py-1 min-h-9 text-sm text-black rounded cursor-pointer hover:bg-alpha-black-50';
        li.textContent = `${item.name} (${item.value})`;
        this.listTarget.appendChild(li);
      });

      this.listTarget.classList.remove("hidden");
      this.show = true;
    } else {
      this.close();
    }
  }

}
