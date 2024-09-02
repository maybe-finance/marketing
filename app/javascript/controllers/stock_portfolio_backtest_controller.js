import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

/**
 * @typedef {Object} OHCLResponseItem
 * @property {string} date
 * @property {number} open
 * @property {number} close
 * @property {number} high
 * @property {number} low
 * @property {number} volume
 */

/**
 * @typedef {Object.<string, OHCLResponseItem[]>} OHCLResponse
 */

export default class extends Controller {
  static targets = ["resultsTemplate", "loadingTemplate", "resultsContainer", "totalAllocation", "totalAllocationWarning"]

  connect() {
    this.totalAllocation = 0;
  }

  /**
   * @param {number} amount
   * @param {'increment' | 'decrement'} action
   */
  updateTotalAllocation(amount, action) {
    if (action === 'increment') {
      this.totalAllocation += amount;
    } else if (action === 'decrement') {
      this.totalAllocation -= amount;
    }
    this.totalAllocationTarget.textContent = `${this.totalAllocation.toFixed(0)}%`;
  }
  /**
   * Fetches OHCLV data for given tickers and date range
   * @param {Object} params
   * @param {string[]} params.tickers - Array of ticker symbols
   * @param {string} params.start_date - Start date in YYYY-MM-DD format
   * @param {string} params.end_date - End date in YYYY-MM-DD format
   * @returns {Promise<OHCLResponse[]>}
   */
  getOHCLVs = async (params) => {
    const searchParams = new URLSearchParams({
      start_date: params.start_date,
      end_date: params.end_date
    });
    params.tickers.map(ticker => {
      searchParams.append("tickers[]", ticker);
    });

    const response = await fetch(`/tickers/open_close?${searchParams.toString()}`);
    const data = await response.json();
    return data;
  }

  distributeEvenly() {
    const allocatorControllers = this.application.controllers.filter(
      controller => controller.identifier === 'stocks-allocator' && !controller.element.classList.contains('hidden')
    );
    const count = allocatorControllers.length;
    if (count > 0) {
      const evenAllocation = Math.floor(100 / count);
      allocatorControllers.forEach((controller, index) => {
        const newAllocation = index === count - 1 ? 100 - (evenAllocation * (count - 1)) : evenAllocation;
        controller.allocationTarget.value = newAllocation;
        controller.updateAllocation();
      });
    }
  }

  /**
   * @param {Event} event 
   */
  async calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const benchmarkStock = formData.get('benchmarkStock');
    const investmentAmount = parseFloat(formData.get('investment_amount').replace(/[^0-9.-]+/g, ''));
    const startDate = formData.get('start_date') || '2000-01-01';
    const endDate = formData.get('end_date')

    /** @type {Array<{ticker: string, allocation: number}>} */
    const stocks = [];

    let totalAllocation = 0;

    Array.from({ length: 10 }, (_, i) => {
      const stock = formData.get(`stock_${i}`);
      const allocation = parseFloat(formData.get(`stock_allocation_${i}`));
      if (stock && !isNaN(allocation)) {
        totalAllocation += allocation;
        stocks.push({ ticker: stock, allocation });
      }
    });

    if (totalAllocation < 100) {
      this.totalAllocationWarningTarget.textContent = "The total allocation is below 100%. Please review and adjust your allocations.";
      this.totalAllocationWarningTarget.classList.remove("hidden");
      return;
    }

    if (totalAllocation > 100) {
      this.totalAllocationWarningTarget.textContent = "The total allocation exceeds 100%. Please review and adjust your allocations.";
      this.totalAllocationWarningTarget.classList.remove("hidden");
      return;
    }

    this.totalAllocationWarningTarget.textContent = "";
    this.totalAllocationWarningTarget.classList.add("hidden");

    this.#renderLoading({ isLoading: true });

    const tickers = [...stocks.map(s => s.ticker), benchmarkStock];
    const ohclvData = await this.getOHCLVs({ tickers, start_date: startDate, end_date: endDate });

    const { chartData, legendData } = this.#calculateChartData(ohclvData, stocks, benchmarkStock, investmentAmount, startDate, endDate);

    const lastDataPoint = chartData[chartData.length - 1];
    const portfolioGrowth = lastDataPoint.portfolio
    const benchmarkGrowth = lastDataPoint.benchmark
    this.#renderLoading({ isLoading: false });

    this.#renderResults({
      portfolioGrowth: this.formatCurrency(portfolioGrowth),
      benchmarkGrowth: this.formatCurrency(benchmarkGrowth),
      chartData: chartData,
      legendData: JSON.stringify(legendData)
    });
  }

  /**
   * @param {number} amount
   */
  formatCurrency(amount) {
    return `$${Intl.NumberFormat('en-US').format(amount.toFixed(0))}`
  }

  /**
   * Retrieves ticker data from the OHCLV data
   * @param {OHCLResponse[]} data - OHCLV data
   * @param {string} ticker - Ticker symbol
   * @returns {OHCLResponseItem[] | undefined}
   */
  getTickerData(data, ticker) {
    return data.find(obj => obj.hasOwnProperty(ticker))?.[ticker];
  }

  /**
   * Calculates chart data for portfolio and benchmark
   * @param {OHCLResponse[]} ohclvData - OHCLV data
   * @param {Array<{ticker: string, allocation: number}>} stocks - Portfolio stocks
   * @param {string} benchmarkStock - Benchmark stock ticker
   * @param {number} investmentAmount - Initial investment amount
   * @param {string} startDate - Start date
   * @param {string} endDate - End date
   * @returns {{chartData: Array<Object>, legendData: Object}}
   */
  #calculateChartData(ohclvData, stocks, benchmarkStock, investmentAmount, startDate, endDate) {
    const chartData = [];
    const allDates = ohclvData.flatMap(stockData => stockData[Object.keys(stockData)[0]].map(item => item.date));
    const uniqueDates = Array.from(new Set(allDates));
    const dateKeys = uniqueDates.sort();

    /** @type {Record<string, number>} */
    let portfolioShares = {};
    let benchmarkShares = 0;

    stocks.forEach(stock => {
      portfolioShares[stock.ticker] = (investmentAmount * stock.allocation / 100) / this.getInitialPrice(ohclvData, stock.ticker);
    });
    benchmarkShares = investmentAmount / this.getInitialPrice(ohclvData, benchmarkStock);

    dateKeys.forEach(date => {
      let portfolioValue = 0;
      stocks.forEach(stock => {
        const price = this.getPriceForDate(ohclvData, stock.ticker, date);
        portfolioValue += portfolioShares[stock.ticker] * price;
      });

      const benchmarkPrice = this.getPriceForDate(ohclvData, benchmarkStock, date);
      const benchmarkValue = benchmarkShares * benchmarkPrice;

      const [year, month, day] = date.split('-');
      const yearMonth = `${new Date(date).toLocaleString('default', { month: 'short' })} ${year}`;

      chartData.push({
        yearMonth,
        year,
        month,
        date,
        portfolio: portfolioValue,
        benchmark: benchmarkValue
      });
    });

    return {
      chartData: chartData,
      legendData: {
        portfolio: {
          name: "Portfolio value",
          fillClass: "fill-pink-500",
          strokeClass: "stroke-pink-500"
        },
        benchmark: {
          name: "Benchmark value",
          fillClass: "fill-blue-500",
          strokeClass: "stroke-blue-500"
        },
      }
    };
  }

  /**
   * @param {OHCLResponse[]} ohclvData
   * @param {string} ticker
   */
  getInitialPrice(ohclvData, ticker) {
    const stockData = ohclvData.find(data => data[ticker]);
    return stockData[ticker][0].close;
  }

  /**
   * @param {OHCLResponse[]} ohclvData
   * @param {string} ticker
   * @param {string} date
   */
  getPriceForDate(ohclvData, ticker, date) {
    const stockData = ohclvData.find(data => data[ticker]);
    const dataPoint = stockData[ticker].find(item => item.date === date);
    return dataPoint ? dataPoint.close : null;
  }

  #renderResults(data) {
    const resultsElement = this.resultsRenderer.render(data);
    this.resultsContainerTarget.innerHTML = "";
    this.resultsContainerTarget.appendChild(resultsElement);
  }

  #renderLoading(data) {
    const loadingElement = this.loadingRenderer.render(data);
    this.resultsContainerTarget.innerHTML = "";
    this.resultsContainerTarget.appendChild(loadingElement);
  }

  get resultsRenderer() {
    return new TemplateRenderer(this.resultsTemplateTarget);
  }

  get loadingRenderer() {
    return new TemplateRenderer(this.loadingTemplateTarget);
  }
}
