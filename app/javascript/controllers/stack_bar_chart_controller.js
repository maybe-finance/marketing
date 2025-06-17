import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static values = {
    data: { type: Object, default: {} },
  };

  #data = [];
  #isMobile = window.innerWidth <= 768;
  #resizeHandler = null;

  dataValueChanged(value) {
    this.#data = value;
    this.#drawChart();
  }

  connect() {
    this.#drawChart();
    this.#addResizeListener();
  }

  disconnect() {
    this.#removeResizeListener();
  }

  #addResizeListener() {
    this.#resizeHandler = this.#debounce(() => {
      this.#isMobile = window.innerWidth <= 768;
      this.#drawChart();
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

  #drawChart() {
    const data = this.#data.segments;
    const desiredHomePrice = this.#data.desiredHomePrice;

    // Use container width instead of fixed widths
    const containerWidth = this.element.clientWidth || 320;
    const margin = this.#isMobile ? { top: 20, right: 10, bottom: 40, left: 10 } : { top: 20, right: 30, bottom: 40, left: 50 };
    const width = Math.max(280, containerWidth - margin.left - margin.right);
    const height = 400 - margin.top - margin.bottom;

    const svg = d3.select(this.element)
      .html("")
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .attr("viewBox", `0 0 ${width + margin.left + margin.right} ${height + margin.top + margin.bottom}`)
      .style("max-width", "100%")
      .style("height", "auto")
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    const subgroups = data.map(d => d.category)
    const stackedData = d3.stack().keys(subgroups)([data.reduce((acc, d) => {
      acc[d.category] = d.value;
      return acc;
    }, {})]);

    const totalValue = data.reduce((sum, d) => sum + d.value, 0);
    if (desiredHomePrice > totalValue) {
      stackedData[stackedData.length - 1][0][1] = desiredHomePrice;
    }

    const x = d3.scaleBand()
      .domain(["Total"])
      .range([0, width])
      .padding([0.2]);

    svg.append("g")
      .attr("transform", `translate(0,${height})`)
      .call(d3.axisBottom(x).tickSize(0))
      .selectAll("text").remove();

    const y = d3.scaleLinear()
      .domain([0, Math.max(d3.max(stackedData, d => d3.max(d, d => d[1])), desiredHomePrice)])
      .range([height, 0]);

    const color = d3.scaleOrdinal()
      .domain(subgroups)
      .range(["#10A861", "#FFCC19", "#FF8329", "#EC2222"]);

    this.#addGrid(svg, width, height, y);

    svg.append("g")
      .selectAll("g")
      .data(stackedData)
      .enter().append("g")
      .attr("fill", d => color(d.key))
      .selectAll("rect")
      .data(d => d)
      .enter().append("rect")
      .attr("x", d => x("Total"))
      .attr("y", d => y(d[1]))
      .attr("height", d => y(d[0]) - y(d[1]))
      .attr("width", x.bandwidth());

    this.#addVerticalLine(svg, width, height);
    this.#addTooltip(svg, data, width, height);
    this.#addLabels(svg, y);
  }

  /**
   * @param {d3.Selection<SVGGElement, unknown, null, undefined>} svg
   * @param {d3.ScaleLinear<number, number>} y
   */
  #addLabels(svg, y) {
    svg.append("g")
      .call(d3.axisLeft(y)
        .tickFormat(d => `$${d / 1000}K`)
        .ticks(6)
      )
      .call(g => g.selectAll(".tick line").remove())
      .selectAll("text")
      .attr("fill", "#737373")
      .attr("x", -8)
      .attr("dy", "0.35em")
      .attr("text-anchor", "end");
  }

  #getColor(category) {
    const colorMap = {
      "Affordable": "#10A861",
      "Good": "#FFCC19",
      "Caution": "#FF8329",
      "Risky": "#EC2222"
    };
    return colorMap[category];
  }

  /**
   * Adds decorative dotted lines
   * @param {d3.Selection<SVGGElement, any, null, undefined>} svg
   * @param {number} width
   * @param {number} height
   * @param {d3.ScaleLinear<number, number>} y
   */
  #addGrid(svg, width, height, y) {
    svg.append("g")
      .attr("class", "grid")
      .call(d3.axisLeft(y)
        .tickSize(-width)
        .tickFormat("")
      )
      .selectAll("line")
      .style("stroke-dasharray", "1, 12")
      .style("stroke", "#B6B6B6")
      .style("stroke-width", 1.5)
      .style("stroke-linecap", "round");
  }

  /**
   * Adds vertical grid lines
   * @param {d3.Selection<SVGGElement, any, null, undefined>} svg
   * @param {number} width
   * @param {number} height
   */
  #addVerticalLine(svg, width, height) {
    const verticalLine = svg.append("line")
      .attr("class", "vertical-line")
      .attr("x1", width / 2)
      .attr("x2", width / 2)
      .attr("y1", 0)
      .attr("y2", height)
      .style("stroke-dasharray", "4,4")
      .style("stroke", "#D6D6D6")
      .style("stroke-width", 1.5);
  }

  /**
   * Adds tooltip
   * @param {d3.Selection<SVGGElement, any, null, undefined>} svg
   * @param {Array} data
   * @param {number} width
   * @param {number} height
   */
  #addTooltip(svg, data, width, height) {
    // Add indicator dot
    const totalValue = d3.sum(data, d => d.value);
    const y = d3.scaleLinear()
      .domain([0, totalValue])
      .range([height, 0]);

    let cumulativeValue = 0;
    const segment = data.find(d => {
      cumulativeValue += d.value;
      return cumulativeValue >= this.#data.desiredHomePrice;
    }) || data[data.length - 1];

    const segmentStart = cumulativeValue - segment.value;
    const segmentCenter = segmentStart + segment.value / 2;
    const indicatorY = y(segmentCenter);

    // Add indicator dot
    const indicatorGroup = svg.append("g")
      .attr("class", "indicator-dot")
      .attr("transform", `translate(${width / 2}, ${indicatorY})`);

    indicatorGroup.append("circle")
      .attr("r", 10)
      .attr("fill", "rgba(97, 114, 243, 0.1)");

    indicatorGroup.append("circle")
      .attr("r", 6)
      .attr("fill", "white");

    indicatorGroup.append("circle")
      .attr("r", 5)
      .attr("fill", "#6172F3");

    const formatter = new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
      notation: "compact",
      compactDisplay: "short"
    });

    const originalValues = data.reduce((acc, item) => {
      acc.push((acc[acc.length - 1] || 0) + item.value);
      return acc;
    }, []);

    const categoryAmounts = data.map((item, index) => {
      const min = index === 0 ? 0 : originalValues[index - 1];
      const max = originalValues[index];
      let range;
      if (index === data.length - 1) {
        range = `Over ${formatter.format(min)}`;
      } else {
        range = index === 0 ? `Up to ${formatter.format(max)}` : `${formatter.format(min)}-${formatter.format(max)}`;
      }
      return `<div class="flex items-center gap-3 py-1 w-40">
           <span class="w-[4px] h-[12px] rounded-full" style="background: ${this.#getColor(item.category)}"></span>
           <span class="text-sm text-gray-900"> ${range}</span>
          </div>`;
    }).reverse().join("");

    const tooltip = d3.select(this.element)
      .append("div")
      .attr("class", "chart-tip")
      .style("position", "absolute")
      .style("opacity", 1)
      .style("background", "white")
      .style("border", "1px solid #ccc")
      .style("padding", "10px")
      .style("pointer-events", "none")
      .style("border-radius", "5px")
      .style("box-shadow", "0 0 10px rgba(0, 0, 0, 0.1)")
      .style('border-radius', '10px')
      .style('left', (this.#isMobile ? (width / 1.7) : (width / 1.5)) + 'px')
      .style('top', `${indicatorY / 1.2}px`)
      .html(categoryAmounts)
  }

}