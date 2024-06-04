import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static values = {
    series: { type: Object, default: {} },
    data: { type: Array, default: [] },
  }
  
  #initialElementWidth = 0
  #initialElementHeight = 0

  connect() {
    this.#rememberInitialElementSize()
    this.#renderBarChart()
  }

  // Normalize data when it is set
  #data = []
  dataValueChanged(value) {
    this.#data = value.map(d => ({
      ...d,
      date: new Date(d.date),
    }))
  }

  #renderBarChart() {
    const x = this.#d3XScale
    const y = this.#d3YScale

    // Append a group for each series, and a rect for each element in the series.
    this.#d3Content
      .append("g")
      .selectAll()
      .data(this.#d3Series)
      .join("g")
        .attr("class", d => this.seriesValue[d.key].className)
      .selectAll("rect")
      .data(D => D.map(d => (d.key = D.key, d)))
      .join("rect")
        .attr("x", d => x(d.data.date))
        .attr("y", d => y(d[1]))
        .attr("height", d => y(d[0]) - y(d[1]))
        .attr("width", x.bandwidth())
  }

  #rememberInitialElementSize() {
    this.#initialElementWidth = this.element.clientWidth
    this.#initialElementHeight = this.element.clientHeight
  }

  get #contentWidth() {
    return this.#initialElementWidth - this.#margin.left - this.#margin.right
  }

  get #contentHeight() {
    return this.#initialElementHeight - this.#margin.top - this.#margin.bottom
  }

  get #margin() {
    if (this.useLabelsValue) {
      return { top: 20, right: 0, bottom: 30, left: 0 }
    } else {
      return { top: 0, right: 0, bottom: 0, left: 0 }
    }
  }
  
  #d3GroupMemo = null
  get #d3Content() {
    if (this.#d3GroupMemo) return this.#d3GroupMemo

    return this.#d3GroupMemo = this.#d3Svg
      .append("g")
      .attr("transform", `translate(${this.#margin.left},${this.#margin.top})`)
  }

  #d3SvgMemo = null
  get #d3Svg() {
    if (this.#d3SvgMemo) return this.#d3SvgMemo

    return this.#d3SvgMemo = this.#d3Element
      .append("svg")
      .attr("width", this.#initialElementWidth)
      .attr("height", this.#initialElementHeight)
      .attr("viewBox", [ 0, 0, this.#initialElementWidth, this.#initialElementHeight ])
  }

  get #d3Element() {
    return d3.select(this.element)
  }

  get #d3Series() {
    const stack = d3.stack()
      .keys(Object.keys(this.seriesValue))

    return stack(this.#data)
  }

  get #d3XScale() {
     return d3.scaleBand()
      .domain(this.#data.map(d => d.date))
      .range([ 0, this.#contentWidth ])
      .padding(0.1);
  }

  get #d3YScale() {
    return d3.scaleLinear()
      .domain([0, d3.max(this.#d3Series, d => d3.max(d, d => d[1]))])
      .rangeRound([this.#contentHeight - this.#margin.bottom, this.#margin.top])
  }
}
