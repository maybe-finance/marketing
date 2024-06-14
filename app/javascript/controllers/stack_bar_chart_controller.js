import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static values = {
    data: { type: Array, default: [] },
  };

  #data = [];
  dataValueChanged(value) {
    this.#data = value;
    this.#drawChart();
  }

  connect() {
    this.#drawChart();
  }

  #drawChart() {
    const data = this.#data;

    const isMobile = window.innerWidth <= 768;
    const margin = isMobile ? { top: 20, right: 10, bottom: 40, left: 10 } : { top: 20, right: 30, bottom: 40, left: 50 };
    const width = (isMobile ? 350 : 600) - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    const svg = d3.select(this.element)
      .html("")
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    const subgroups = data.map(d => d.category).reverse();
    const stackedData = d3.stack().keys(subgroups)([data.reduce((acc, d) => {
      acc[d.category] = d.value;
      return acc;
    }, {})]);

    const x = d3.scaleBand()
      .domain(["Total"])
      .range([0, width])
      .padding([0.2]);

    svg.append("g")
      .attr("transform", `translate(0,${height})`)
      .call(d3.axisBottom(x).tickSize(0))
      .selectAll("text").remove();

    const y = d3.scaleLinear()
      .domain([0, d3.max(stackedData, d => d3.max(d, d => d[1]))])
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

    this.#addTooltip(svg, data);

    const maxValue = d3.max(data, d => d.value);
    const increment = 100000;
    const customLabels = d3.range(0, maxValue + increment, increment).map(value => ({
      value: (value / maxValue) * height,
      label: `$${(value / 1000).toFixed(0)}k`
    }));

    svg.selectAll(".custom-label")
      .data(customLabels)
      .enter().append("text")
      .attr("fill", "#737373")
      .attr("x", -8)
      .attr("y", d => height - d.value)
      .attr("dy", "0.35em")
      .attr("text-anchor", "end")
      .text(d => d.label);
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
   * Adds tooltip
   * @param {d3.Selection<SVGGElement, any, null, undefined>} svg
   * @param {Array} data
   */
  #addTooltip(svg, data) {
    const tooltip = d3.select(this.element)
      .append("div")
      .attr("class", "chart-tip")
      .style("position", "absolute")
      .style("opacity", 0)
      .style("background", "white")
      .style("border", "1px solid #ccc")
      .style("padding", "10px")
      .style("pointer-events", "none")
      .style("border-radius", "5px")
      .style("box-shadow", "0 0 10px rgba(0, 0, 0, 0.1)");

    svg.on('mouseover', (event) => {
      d3.select(".chart-tip")
        .style('opacity', '1')
        .html('Amount: <strong>$' + d3.format(",")(d.data[d.key]) + '</strong>')
        .style("left", (event.pageX + 5) + "px")
        .style("top", (event.pageY - 28) + "px");
    }).on('mouseout', function () {
      d3.select(".chart-tip")
        .style('opacity', '0');
    });

    svg.on('mouseover', (event) => {
      const formatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
        notation: "compact",
        compactDisplay: "short"
      });
      const categoryAmounts = data.map((item, index) => {
        const min = index === 0 ? 0 : data[index - 1].value;
        const max = item.value;
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

      tooltip
        .style('opacity', 1)
        .html(categoryAmounts)
        .style('left', (event.pageX + 10) + 'px')
        .style('border-radius', '10px')
        .style('top', (event.pageY - 28) + 'px');
    })
      .on('mouseout', function () {
        tooltip.style('opacity', 0);
      });
  }

}