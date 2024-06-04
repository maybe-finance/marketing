import { Controller } from "@hotwired/stimulus"
import tailwindColors from "@maybe/tailwindcolors"
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
    this.#drawGridlines()
    this.#drawBarChart()
    this.#installTooltip()
  }

  // Normalize data when it is set
  #data = []
  dataValueChanged(value) {
    this.#data = value.map(d => ({
      ...d,
      date: new Date(d.date),
    }))
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

  #drawBarChart() {
    const x = this.#d3XScale
    const y = this.#d3YScale

    // Append a group for each series, and a rect for each element in the series.
    this.#d3Content
      .append("g")
      .selectAll()
      .data(this.#d3Series)
      .join("g")
        .attr("class", d => this.seriesValue[d.key].fillClass)
      .selectAll("rect")
      .data(D => D.map(d => (d.key = D.key, d)))
      .join("rect")
        .attr("x", d => x(d.data.date))
        .attr("y", d => y(d[1]))
        .attr("height", d => y(d[0]) - y(d[1]))
        .attr("width", x.bandwidth())
  }

  #drawGridlines() {
    const yGrid = d3.axisRight(this.#d3YScale)
      .ticks(15)
      .tickSize(this.#contentWidth)
      .tickFormat("")

    const gridlines = this.#d3Content
      .append("g")
      .attr("class", "d3gridlines")
      .call(yGrid)

    gridlines
      .selectAll("line")
      .style("stroke", tailwindColors["alpha-black"][500]) // Set your desired color here
      .style("stroke-dasharray", "3 9") // This makes the lines dashed
      .style("stroke-width", "1"); // Optional: adjust the width of the lines

    gridlines
      .select(".domain")
      .remove()
  }

  #installTooltip() {
    this.#d3Content
      .append("rect")
      .attr("width", this.#contentWidth)
      .attr("height", this.#contentHeight)
      .attr("fill", "none")
      .attr("pointer-events", "all")
      .on("mousemove", (event) => {
        const x = this.#d3XScale
        const d = this.#findDatumByPointer(event)
        console.log(x)

        this.#d3Content.selectAll(".guideline").remove()

        this.#d3Content
          .insert("rect", ":first-child")
          .attr("class", "guideline")
          .attr("x", x(d.date) - x.padding() * 2)
          .attr("y", 0)
          .attr("width", x.bandwidth() + x.padding() * 4)
          .attr("height", this.#contentHeight)
          .attr("fill", tailwindColors["alpha-black"][50])

        this.#d3Tooltip
          .html(this.#tooltipTemplate(d))
          .style("opacity", 1)
          .style("z-index", 999)
          .style("left", this.#tooltipLeft(event) + "px")
          .style("top", event.pageY - 10 + "px")
      })
      .on("mouseout", (event) => {
        const hoveringOnGuideline = event.toElement?.classList.contains("guideline")
        if (!hoveringOnGuideline) {
          this.#d3Content.selectAll(".guideline").remove()
          this.#d3Tooltip.style("opacity", 0)
        }
      })
  }

  #tooltipLeft(event) {
    const estimatedTooltipWidth = 250
    const pageWidth = document.body.clientWidth
    const tooltipX = event.pageX + 10
    const overflowX = tooltipX + estimatedTooltipWidth - pageWidth
    const adjustedX = overflowX > 0 ? event.pageX - overflowX - 20 : tooltipX
    return adjustedX
  }

  #tooltipTemplate(datum) {
    return(`
      <div style="margin-bottom: 4px; color: ${tailwindColors.gray[500]};">
        ${d3.timeFormat("%b %d, %Y")(datum.date)}
      </div>

      ${
        Object.entries(this.seriesValue).reverse().map(([key, series]) => `
          <div style="display: flex; align-items: center; gap: 16px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <svg width="10" height="10">
                <circle
                  cx="5"
                  cy="5"
                  r="4"
                  class="${series.strokeClass}"
                  fill="transparent"
                  stroke-width="1"></circle>
              </svg>

              <span>
                ${
                  new Intl.NumberFormat(navigator.language, {
                    style: "currency",
                    currencyDisplay: "narrowSymbol",
                    currency: "USD",
                    maximumFractionDigits: 0,
                  }).format(datum[key])
                }
              </span>
            </div>
          </div>
        `).join("")
      }
    `)
  }

  #d3TooltipMemo = null
  get #d3Tooltip() {
    if (this.#d3TooltipMemo) return this.#d3TooltipMemo

    return this.#d3TooltipMemo = this.#d3Element
      .append("div")
      .style("position", "absolute")
      .style("padding", "8px")
      .style("font", "14px Inter, sans-serif")
      .style("background", tailwindColors.white)
      .style("border", `1px solid ${tailwindColors["alpha-black"][100]}`)
      .style("border-radius", "10px")
      .style("pointer-events", "none")
      .style("opacity", 0)
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
      .padding(.4);
  }

  get #d3YScale() {
    return d3.scaleLinear()
      .domain([0, d3.max(this.#d3Series, d => d3.max(d, d => d[1]))])
      .rangeRound([this.#contentHeight - this.#margin.bottom, this.#margin.top])
  }

  #findDatumByPointer(event) {
    const x = this.#d3XScale
    const [xPos] = d3.pointer(event)

    const index = Math.floor((xPos - x.bandwidth() / 2) / x.step())

    if (index < 0) return this.#data[0]
    if (index >= this.#data.length) return this.#data[this.#data.length - 1]
    return this.#data[index]
  }
}
