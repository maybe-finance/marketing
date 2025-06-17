import { Controller } from "@hotwired/stimulus";
import tailwindColors from "@maybe/tailwindcolors";
import * as d3 from "d3";

export default class extends Controller {
  static targets = ["loadingSpinner"]
  static values = {
    series: { type: Object, default: {} },
    data: { type: Array, default: [] }
  };

  #initialElementWidth = 0;
  #initialElementHeight = 0;
  #resizeHandler = null;

  connect() {
    this.#rememberInitialElementSize();
    this.showLoading();
    this.#drawGridlines();
    this.#drawChart();
    this.#drawXAxis();
    this.#installTooltip();
    this.hideLoading();
    this.#addResizeListener();
  }

  disconnect() {
    this.#removeResizeListener();
  }

  #redrawChart() {
    this.#clearChart();
    this.#rememberInitialElementSize();
    this.showLoading();
    this.#drawGridlines();
    this.#drawChart();
    this.#drawXAxis();
    this.#installTooltip();
    this.hideLoading();
  }

  #clearChart() {
    this.#d3TooltipMemo = null;
    this.#d3GroupMemo = null;
    this.#d3SvgMemo = null;
    this.#d3Element.selectAll("*").remove();
  }

  #addResizeListener() {
    this.#resizeHandler = this.#debounce(() => {
      this.#redrawChart();
    }, 250);
    window.addEventListener('resize', this.#resizeHandler);
  }

  #removeResizeListener() {
    if (this.#resizeHandler) {
      window.removeEventListener('resize', this.#resizeHandler);
    }
  }

  #debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  showLoading() {
    if (this.hasLoadingSpinnerTarget) {
      this.loadingSpinnerTarget.classList.remove("hidden");
    }
  }

  hideLoading() {
    if (this.hasLoadingSpinnerTarget) {
      this.loadingSpinnerTarget.classList.add("hidden");
    }
  }

  #data = [];
  dataValueChanged(value) {
    this.#data = value.map(d => ({
      ...d,
      date: new Date(d.date)
    }));
  }

  #rememberInitialElementSize() {
    this.#initialElementWidth = this.element.clientWidth;
    this.#initialElementHeight = this.element.clientHeight;
  }

  get #contentWidth() {
    return this.#initialElementWidth - this.#margin.left - this.#margin.right;
  }

  get #contentHeight() {
    return this.#initialElementHeight - this.#margin.top - this.#margin.bottom;
  }

  get #margin() {
    return { top: 0, right: 0, bottom: 40, left: 0 };
  }

  #drawChart() {
    const x = this.#d3XScale;
    const y = this.#d3YScale;

    // Create gradient
    const gradient = this.#d3Svg.append("defs")
      .append("linearGradient")
      .attr("id", "exchange-rate-gradient")
      .attr("x1", "0%").attr("y1", "0%")
      .attr("x2", "0%").attr("y2", "100%");

    gradient.append("stop")
      .attr("offset", "0%")
      .attr("stop-color", tailwindColors.blue[500])
      .attr("stop-opacity", 0.2);

    gradient.append("stop")
      .attr("offset", "100%")
      .attr("stop-color", tailwindColors.blue[500])
      .attr("stop-opacity", 0);

    // Draw the area
    this.#d3Content
      .append("path")
      .datum(this.#data)
      .attr("fill", "url(#exchange-rate-gradient)")
      .attr("d", d3.area()
        .x(d => x(d.date))
        .y0(y(d3.min(this.#data, d => d.rate) * 0.999))
        .y1(d => y(d.rate))
        .curve(d3.curveMonotoneX)
      );

    // Draw the line
    this.#d3Content
      .append("path")
      .datum(this.#data)
      .attr("fill", "none")
      .attr("stroke", tailwindColors.blue[500])
      .attr("stroke-width", 3)
      .attr("stroke-linecap", "round")
      .attr("d", d3.line()
        .x(d => x(d.date))
        .y(d => y(d.rate))
        .curve(d3.curveMonotoneX)
      );
  }

  #drawGridlines() {
    const axisGenerator = d3.axisRight(this.#d3YScale)
      .ticks(10)
      .tickSize(this.#contentWidth)
      .tickFormat("");

    const gridlines = this.#d3Content
      .append("g")
      .attr("class", "d3gridlines")
      .call(axisGenerator);

    gridlines
      .selectAll("line")
      .style("stroke", tailwindColors["alpha-black"][500])
      .style("stroke-dasharray", "1 8")
      .style("stroke-width", "1")
      .style("stroke-linecap", "round");

    gridlines
      .select(".domain")
      .remove();
  }

  #drawXAxis() {
    const first = this.#data[0];
    const last = this.#data[this.#data.length - 1];

    const axisGenerator = d3.axisBottom(this.#d3XScale)
      .tickValues([first.date, last.date])
      .tickSize(0)
      .tickFormat(d3.timeFormat("%B %Y"));

    const axis = this.#d3Content
      .append("g")
      .attr("transform", `translate(0, ${this.#contentHeight - this.#margin.bottom / 2 - 6})`)
      .call(axisGenerator);

    axis
      .select(".domain")
      .remove();

    axis
      .selectAll(".tick text")
      .style("fill", tailwindColors.gray[500])
      .style("font-size", "14px")
      .style("font-weight", "400")
      .attr("text-anchor", (_, i) => i === 0 ? "start" : "end");
  }

  #installTooltip() {
    const dot = this.#d3Content
      .append("g")
      .attr("class", "focus")
      .style("display", "none");

    dot.append("circle")
      .attr("r", 4)
      .attr("fill", tailwindColors.blue[500])
      .attr("stroke", "white")
      .attr("stroke-width", 2);

    this.#d3Content
      .append("rect")
      .attr("width", this.#contentWidth)
      .attr("height", this.#contentHeight)
      .attr("fill", "none")
      .attr("pointer-events", "all")
      .on("mouseover", () => dot.style("display", null))
      .on("mouseout", () => {
        dot.style("display", "none");
        this.#d3Content.selectAll(".guideline").remove();
        this.#d3Tooltip.style("opacity", 0);
      })
      .on("mousemove", (event) => {
        const x = this.#d3XScale;
        const d = this.#findDatumByPointer(event);
        const dataX = x(d.date);

        dot.attr("transform", `translate(${dataX}, ${this.#d3YScale(d.rate)})`);

        this.#d3Content.selectAll(".guideline").remove();

        this.#d3Content
          .insert("line", ":first-child")
          .attr("class", "guideline")
          .attr("stroke", tailwindColors["alpha-black"][50])
          .style("stroke-dasharray", "5")
          .style("stroke-width", "2")
          .style("stroke-linecap", "round")
          .attr("x1", dataX)
          .attr("y1", 0 + this.#margin.top)
          .attr("x2", dataX)
          .attr("y2", this.#contentHeight - this.#margin.bottom);

        this.#d3Tooltip
          .html(this.#tooltipTemplate(d))
          .style("opacity", 1)
          .style("z-index", 999)
          .style("left", `${event.pageX + 10}px`)
          .style("top", `${event.pageY}px`);
      });
  }

  #tooltipTemplate(datum) {
    return (`
      <div class="mb-1 text-gray-500 font-medium">
        ${datum.yearMonth}
      </div>
      <div class="flex items-center gap-4">
        <div class="flex items-center gap-2">
          <svg width="4" height="12">
            <rect rx="2" ry="2" class="fill-blue-500" width="4" height="12"></rect>
          </svg>
          <span class="font-medium">${datum.rate.toFixed(6)}</span>
        </div>
      </div>
    `);
  }

  #d3TooltipMemo = null;
  get #d3Tooltip() {
    if (this.#d3TooltipMemo) return this.#d3TooltipMemo;

    return this.#d3TooltipMemo = this.#d3Element
      .append("div")
      .attr("class", "absolute text-sm bg-white border border-alpha-black-100 p-2 rounded-lg shadow-sm")
      .style("pointer-events", "none")
      .style("opacity", 0);
  }

  #d3GroupMemo = null;
  get #d3Content() {
    if (this.#d3GroupMemo) return this.#d3GroupMemo;

    return this.#d3GroupMemo = this.#d3Svg
      .append("g")
      .attr("transform", `translate(${this.#margin.left},${this.#margin.top})`);
  }

  #d3SvgMemo = null;
  get #d3Svg() {
    if (this.#d3SvgMemo) return this.#d3SvgMemo;

    return this.#d3SvgMemo = this.#d3Element
      .append("svg")
      .attr("width", this.#initialElementWidth)
      .attr("height", this.#initialElementHeight)
      .attr("viewBox", [0, 0, this.#initialElementWidth, this.#initialElementHeight])
      .style("max-width", "100%")
      .style("height", "auto");
  }

  get #d3Element() {
    return d3.select(this.element);
  }

  get #d3XScale() {
    const dateExtent = d3.extent(this.#data, d => d.date);
    return d3.scaleTime()
      .domain(dateExtent)
      .range([0, this.#contentWidth]);
  }

  get #d3YScale() {
    const rates = this.#data.map(d => d.rate);
    const min = d3.min(rates);
    const max = d3.max(rates);
    const padding = (max - min) * 0.1;

    return d3.scaleLinear()
      .domain([min - padding, max + padding])
      .range([this.#contentHeight - this.#margin.bottom, this.#margin.top]);
  }

  #findDatumByPointer(event) {
    const x = this.#d3XScale;
    const [xPos] = d3.pointer(event);
    const bisectDate = d3.bisector(d => d.date).left;
    const date = x.invert(xPos);
    const index = bisectDate(this.#data, date, 1);

    if (index === 0) return this.#data[0];
    if (index >= this.#data.length) return this.#data[this.#data.length - 1];

    const d0 = this.#data[index - 1];
    const d1 = this.#data[index];
    return date - d0.date > d1.date - date ? d1 : d0;
  }
}