import { Controller } from "@hotwired/stimulus";
import tailwindColors from "@maybe/tailwindcolors";
import * as d3 from "d3";

export default class extends Controller {
  static values = {
    series: { type: Object, default: {} },
    data: { type: Array, default: [] },
    useLabels: { type: Boolean, default: true },
  };

  #initialElementWidth = 0;
  #initialElementHeight = 0;
  #resizeHandler = null;

  connect() {
    this.#rememberInitialElementSize();
    this.#drawGridlines();
    this.#drawTwoLinesChart();
    if (this.useLabelsValue) {
      this.#drawXAxis();
      this.#drawLegend();
    }
    this.#installTooltip();
    this.#addResizeListener();
  }

  disconnect() {
    this.#removeResizeListener();
  }

  #redrawChart() {
    this.#clearChart();
    this.#rememberInitialElementSize();
    this.#drawGridlines();
    this.#drawTwoLinesChart();
    if (this.useLabelsValue) {
      this.#drawXAxis();
      this.#drawLegend();
    }
    this.#installTooltip();
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

  // Normalize data when it is set
  #data = [];
  dataValueChanged(value) {
    this.#data = value.map(d => ({
      ...d,
      date: new Date(d.date),
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
    if (this.useLabelsValue) {
      return { top: 10, right: 0, bottom: 40, left: 0 };
    } else {
      return { top: 0, right: 0, bottom: 0, left: 0 };
    }
  }

  #drawTwoLinesChart() {
    const x = this.#d3XScale;
    const y = this.#d3YScale;

    this.#d3Content
      .append("g")
      .selectAll()
      .data(this.#d3Series)
      .join("g")
      .attr("class", d => this.seriesValue[d.key].strokeClass)
      .append("path")
      .attr("fill", "none")
      .attr("stroke", d => this.seriesValue[d.key].strokeClass)
      .attr("stroke-width", 3)
      .attr("stroke-dasharray", (d, i) => i === 0 ? "9" : null)
      .attr("stroke-linecap", "round")
      .attr("d", d => {
        return d3.line()
          .x(d => x(d.data.date))
          .y(d => y(d[1] - d[0]))
          .curve(d3.curveMonotoneX)(d);
      });

    this.#createGradient("line-gradient-1", "#7839ee");
    this.#createGradient("line-gradient-2", "#f23e94");

    this.#d3Content
      .append("g")
      .selectAll()
      .data(this.#d3Series)
      .join("g")
      .attr("class", d => this.seriesValue[d.key].fillClass)
      .append("path")
      .attr("fill", (d, i) => i === 0 ? "url(#line-gradient-1)" : "url(#line-gradient-2)")
      .attr("d", d => d3.area()
        .x(d => x(d.data.date))
        .y0(y(0))
        .y1(d => y(d[1] - d[0]))
        .curve(d3.curveMonotoneX)(d)
      );
  }

  #createGradient(id, color) {
    const gradient = this.#d3Content.append("defs")
      .append("linearGradient")
      .attr("id", id)
      .attr("x1", 0).attr("y1", 0)
      .attr("x2", 0).attr("y2", 1);

    gradient.append("stop")
      .attr("offset", "25%")
      .attr("stop-color", color)
      .style("stop-opacity", 0.10);

    gradient.append("stop")
      .attr("offset", "100%")
      .attr("stop-color", color)
      .style("stop-opacity", 0);
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
    const year1 = this.#data[0].date;
    const yearN = this.#data[this.#data.length - 1];

    const axisGenerator = d3.axisBottom(this.#d3XScale)
      .tickValues([year1, yearN.date])
      .tickSize(0)
      .tickFormat((date, i) => {
        if (i === 0) return "Year 1";
        if (i === 1) return `Year ${yearN.year}`;
      });

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

  #drawLegend() {
    const legend = this.#d3Content
      .append("g");

    let offsetX = 0;
    Object.values(this.seriesValue).forEach((series, i) => {
      const item = legend
        .append("g")
        .attr("transform", `translate(${offsetX}, 0)`);

      item.append("rect")
        .attr("height", 12)
        .attr("width", 4)
        .attr("class", series.fillClass)
        .attr("rx", 2)
        .attr("ry", 2);


      item.append("text")
        .attr("x", 10)
        .attr("y", 10)
        .attr("text-anchor", "start")
        .style("fill", tailwindColors.gray[900])
        .style("font-size", "14px")
        .style("font-weight", "400")
        .text(series.name);

      const itemWidth = item.node().getBBox().width;
      offsetX += itemWidth + 12;
    });

    const legendWidth = legend.node().getBBox().width;
    legend.attr("transform", `translate(${this.#contentWidth / 2 - legendWidth / 2}, ${this.#contentHeight})`);
  }

  #createDot(className, fillClass) {
    const dot = this.#d3Content.append("g")
      .attr("class", className)
      .style("display", "none");

    dot.append("circle")
      .attr("r", 4.5)
      .attr("class", fillClass);

    dot.append("circle")
      .attr("r", 13.5)
      .attr("class", fillClass)
      .style("opacity", 0.15);

    return dot;
  };


  #installTooltip() {
    const dot1 = this.#createDot("focus", this.seriesValue.interest.fillClass);
    const dot2 = this.#createDot("focus", this.seriesValue.contributed.fillClass);

    this.#d3Content
      .append("rect")
      .attr("width", this.#contentWidth)
      .attr("height", this.#contentHeight)
      .attr("fill", "none")
      .attr("pointer-events", "all")
      .on("mouseover", () => {
        dot1.style("display", null);
        dot2.style("display", null);
      })
      .on("mouseout", (event) => {
        const hoveringOnGuideline = event.toElement?.classList.contains("guideline");
        if (!hoveringOnGuideline) {
          this.#d3Content.selectAll(".guideline").remove();
          this.#d3Tooltip.style("opacity", 0);
          dot1.style("display", "none");
          dot2.style("display", "none");
        }
      })
      .on("mousemove", (event) => {
        const x = this.#d3XScale;
        const d = this.#findDatumByPointer(event);

        const dataX = x(d.date);

        dot1.attr("transform", `translate(${dataX}, ${this.#d3YScale(d.interest)})`);
        dot2.attr("transform", `translate(${dataX}, ${this.#d3YScale(d.contributed)})`);

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

        const tooltipX = dataX;
        const tooltipY = this.#d3YScale(d.contributed);
        const tooltipMarginX = 50;

        this.#d3Tooltip
          .html(this.#tooltipTemplate(d))
          .style("opacity", 1)
          .style("z-index", 999)
          .style("left", tooltipX + tooltipMarginX + "px")
          .style("top", tooltipY + "px")
          .style("transform", () => {
            const tooltipElement = this.#d3Tooltip.node();
            const realTooltipWidth = tooltipElement.getBoundingClientRect().width;
            const mouseX = event.clientX;
            const overflowX = mouseX + realTooltipWidth - document.body.clientWidth + tooltipMarginX;
            const adjustedX = overflowX > 0 ? `translateX(${-(overflowX + realTooltipWidth, realTooltipWidth + tooltipMarginX)}px)` : '';
            return adjustedX;
          });
      });
  }

  #tooltipTemplate(datum) {
    const formatCurrency = value => new Intl.NumberFormat(navigator.language, {
      style: "currency",
      currencyDisplay: "narrowSymbol",
      currency: "USD",
      maximumFractionDigits: 0,
    }).format(value);

    return (`
      <div class="mb-1 text-gray-500 font-medium">
        Year ${datum.year}
      </div>
      ${Object.entries(this.seriesValue).reverse().map(([key, series]) => `
        <div class="flex items-center gap-4">
          <div class="flex items-center gap-2">
            <svg width="4" height="12">
              <rect rx="2" ry="2" class="${series.fillClass}" width="4" height="12"></rect>
            </svg>
            <span class="font-medium">${formatCurrency(datum[key])}</span>
          </div>
        </div>
      `).join("")}
      <hr class="my-2">
      <div class="flex items-center gap-4">
        <div class="flex items-center gap-2">
          <span class="text-gray-500 whitespace-nowrap">Total value:</span>
          <span class="font-medium">${formatCurrency(datum.currentTotalValue)}</span>
        </div>
      </div>
    `);
  }

  #d3TooltipMemo = null;
  get #d3Tooltip() {
    if (this.#d3TooltipMemo) return this.#d3TooltipMemo;

    return this.#d3TooltipMemo = this.#d3Element
      .append("div")
      .attr("class", "absolute text-sm bg-white border border-alpha-black-100 p-2 rounded-lg")
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

    this.#d3SvgMemo = this.#d3Element
      .append("svg")
      .attr("width", this.#initialElementWidth)
      .attr("height", this.#initialElementHeight)
      .attr("viewBox", [0, 0, this.#initialElementWidth, this.#initialElementHeight])
      .style("max-width", "100%")
      .style("height", "auto");

    this.#d3SvgMemo.append("defs")
      .append("clipPath")
      .attr("id", "rounded-top")
      .append("path")
      .attr("d", "M0,10 Q0,0 10,0 H90 Q100,0 100,10 V100 H0 Z");

    return this.#d3SvgMemo;
  }

  get #d3Element() {
    return d3.select(this.element);
  }

  get #d3Series() {
    const stack = d3.stack()
      .keys(Object.keys(this.seriesValue));

    return stack(this.#data);
  }

  get #d3XScale() {
    const dateExtent = d3.extent(this.#data, d => d.date);
    return d3.scaleTime()
      .domain([d3.timeDay.offset(dateExtent[0], -(this.#data.length * 15)), d3.timeDay.offset(dateExtent[1], this.#data.length * 15)])
      .range([0, this.#contentWidth]);
  }

  get #d3YScale() {
    return d3.scaleLinear()
      .domain([0, d3.max(this.#d3Series, d => d3.max(d, d => d[1] - d[0]))])
      .rangeRound([this.#contentHeight - this.#margin.bottom, this.#margin.top]);
  }

  #findDatumByPointer(event) {
    const x = this.#d3XScale;
    const [xPos] = d3.pointer(event);

    // Find the closest date to the xPos
    const bisectDate = d3.bisector(d => d.date).left;
    const date = x.invert(xPos);
    const index = bisectDate(this.#data, date, 1);

    // Boundary checks
    if (index === 0) return this.#data[0];
    if (index >= this.#data.length) return this.#data[this.#data.length - 1];

    const d0 = this.#data[index - 1];
    const d1 = this.#data[index];
    const d = date - d0.date > d1.date - date ? d1 : d0;

    return d;
  }
}

