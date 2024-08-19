import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static targets = ["priceDisplay", "changeDisplay", "loadingSpinner"]
  static values = {
    data: Object,
    symbol: String
  }

  connect() {
    this.drawChart()
  }

  drawChart() {
    const data = this.dataValue
    const prices = data.prices

    if (this.hasPriceDisplayTarget && this.hasChangeDisplayTarget) {
      this.updatePriceAndChangeDisplay(data);
    }

    const margin = { top: 20, right: 0, bottom: 0, left: 0 }
    const width = this.element.clientWidth - margin.left - margin.right
    const height = 150 - margin.top - margin.bottom

    const chartElement = this.element.querySelector('#stock-chart')
    if (!chartElement) {
      return;
    }
    chartElement.classList.remove('hidden')
    this.loadingSpinnerTarget.classList.add('hidden')

    chartElement.style.position = 'relative';

    d3.select(chartElement).select("svg").remove()

    const svg = d3.select(chartElement)
      .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`)

    const x = d3.scaleTime()
      .domain(d3.extent(prices, d => new Date(d.date)))
      .range([0, width])

    const y = d3.scaleLinear()
      .domain([d3.min(prices, d => d.low), d3.max(prices, d => d.high)])
      .range([height, 0])

    const gradient = svg.append("defs")
      .append("linearGradient")
      .attr("id", "line-gradient")
      .attr("gradientUnits", "userSpaceOnUse")
      .attr("x1", 0)
      .attr("y1", y(d3.min(prices, d => d.low)))
      .attr("x2", 0)
      .attr("y2", y(d3.max(prices, d => d.high)))
    
    gradient.append("stop")
      .attr("offset", "0%")
      .attr("stop-color", "#10B981")
    
    gradient.append("stop")
      .attr("offset", "100%")
      .attr("stop-color", "#10B981")

    const line = d3.line()
      .x(d => x(new Date(d.date)))
      .y(d => y(d.close))

    svg.append("path")
      .datum(prices)
      .attr("fill", "none")
      .attr("stroke", "url(#line-gradient)")
      .attr("stroke-width", 2)
      .attr("d", line)

    const focus = svg.append("g")
      .attr("class", "focus")
      .style("display", "none")

    focus.append("line")
      .attr("class", "hover-line")
      .attr("y1", 0)
      .attr("y2", height)
      .style("stroke", "#E7E7E7")
      .style("stroke-width", 1)

    focus.append("circle")
      .attr("r", 4.5)
      .attr("fill", "#10B981")
      .attr("stroke", "white")
      .attr("stroke-width", 2)

    const tooltip = d3.select(chartElement)
      .append("div")
      .attr("class", "stock-chart-tooltip")
      .style("opacity", 0)
      .style("position", "absolute")
      .style("background-color", "rgba(255, 255, 255)")
      .style("border", "1px solid #ECECEC")
      .style("border-radius", "8px")
      .style("padding", "8px")
      .style("box-shadow", "0px 1px 2px 0px rgba(11, 11, 11, 0.05)")
      .style("pointer-events", "none")
      .style("font-size", "12px")
      .style("z-index", "9999")
      .style("transition", "opacity 0.2s ease-in-out");

    svg.append("rect")
      .attr("class", "overlay")
      .attr("width", width)
      .attr("height", height)
      .style("opacity", 0)
      .on("mouseover", () => {
        focus.style("display", null);
        tooltip.style("opacity", 1);
      })
      .on("mouseout", () => {
        focus.style("display", "none");
        tooltip.style("opacity", 0);
      })
      .on("mousemove", mousemove)

    function mousemove(event) {
      const [mouseX, mouseY] = d3.pointer(event);
      const bisect = d3.bisector(d => new Date(d.date)).left
      const x0 = x.invert(mouseX)
      const i = bisect(prices, x0, 1)
      const d0 = prices[i - 1]
      const d1 = prices[i]
      const d = x0 - new Date(d0.date) > new Date(d1.date) - x0 ? d1 : d0
      const prevD = prices[Math.max(0, i - 1)]
      
      const xPos = x(new Date(d.date))
      const yPos = y(d.close)
      
      focus.attr("transform", `translate(${xPos},0)`)
      focus.select("circle").attr("cy", yPos)
      focus.select("line").attr("y2", height)
      
      const change = d.close - prevD.close
      const changePercent = ((change / prevD.close) * 100).toFixed(2)
      const changeText = `${change >= 0 ? '+' : ''}$${change.toFixed(2)} (${changePercent}%)`
      
      tooltip.html(`
        <div class="font-semibold">${d3.timeFormat("%b %d, %Y")(new Date(d.date))}</div>
        <div>$${d.close.toFixed(2)}</div>
        <div style="color: ${change >= 0 ? '#10B981' : '#EF4444'}">${changeText}</div>
      `)

      const tooltipNode = tooltip.node();
      const tooltipRect = tooltipNode.getBoundingClientRect();

      let tooltipX = xPos + 10;
      let tooltipY = yPos - tooltipRect.height / 2;

      if (tooltipX + tooltipRect.width > width) {
        tooltipX = xPos - tooltipRect.width - 10;
      }

      if (tooltipY < 0) {
        tooltipY = 0;
      } else if (tooltipY + tooltipRect.height > height) {
        tooltipY = height - tooltipRect.height;
      }

      tooltip
        .style("left", `${tooltipX}px`)
        .style("top", `${tooltipY}px`)
        .style("opacity", 1);
    }
  }

  updatePriceAndChangeDisplay(data) {
    this.priceDisplayTarget.textContent = `$${data.latest_price.toFixed(2)}`
    const changeText = `${data.price_change >= 0 ? '+' : ''}${data.price_change.toFixed(2)} (${data.price_change_percentage.toFixed(2)}%) today`
    this.changeDisplayTarget.textContent = changeText
    this.changeDisplayTarget.classList.remove('text-green-500', 'text-red-500')
    this.changeDisplayTarget.classList.add(data.price_change >= 0 ? 'text-green-500' : 'text-red-500')
  }

  updateTimeRange(event) {
    const timeRange = event.target.dataset.timeRange;
    
    this.element.querySelectorAll('button').forEach(btn => {
      btn.classList.remove('bg-gray-50', 'text-gray-700')
      btn.classList.add('bg-transparent', 'text-gray-500')
    })
    event.target.classList.remove('bg-transparent', 'text-gray-500')
    event.target.classList.add('bg-gray-50', 'text-gray-700')

    this.loadingSpinnerTarget.classList.remove('hidden')
    this.element.querySelector('#stock-chart').classList.add('hidden')

    const url = `/stocks/${this.symbolValue}/chart?time_range=${timeRange}`
    
    fetch(url, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      this.dataValue = data
      this.drawChart()
    })
    .catch(error => {
      this.loadingSpinnerTarget.classList.add('hidden')
      this.element.querySelector('#stock-chart').innerHTML = '<p class="text-red-500">Error loading chart data. Please try again.</p>'
    })
  }
}