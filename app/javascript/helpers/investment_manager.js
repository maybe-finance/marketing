/**
 * @typedef {Object} AssetRowDto
 * @property {string} year
 * @property {number} price
 */

/**
 * @typedef {Object.<string, AssetRowDto>} RawStockData
 */

const DOWNSIDE_DEVIATION_TARGET = 0;

const RiskLevel = {
  LOW: "Low",
  MODERATE: "Moderate",
  HIGH: "High",
}

const riskLevelConfig = {
  [RiskLevel.LOW]: {
    label: "Low",
    color: "text-green",
    maxDownsideDeviation: 1.23,
  },
  [RiskLevel.MODERATE]: {
    label: "Moderate",
    color: "text-yellow",
    maxDownsideDeviation: 2.31,
  },
  [RiskLevel.HIGH]: {
    label: "High",
    color: "text-orange",
    maxDownsideDeviation: null,
  },
};

/**
 * This handles the computations for the
 * bogle heads growth calculator. The calculation of the
 * following are of particular note
 * - Generation of chart data.
 *   - computes final value of a porfiolio at the end of 
 *   - each year for the past 20 years.
 * - Calculating Percentage Returns Total
 * - Calculating final value of investment
 * - computing risk level and associated values for 
 *   - Downside Deviation
 *   - Maximum drawdown percentage
 * 
 * - Type declarations here are supposed to be documentary and to help us reason about the computations
 */
export default class InvestmentManager {
  /**
   * @type {number}
   */
  investmentAmount;

  /**
   * @type {Object.<string, number>}
   */
  fundAllocation;

  /**
   * @type {RawStockData}
   */
  rawStockData;

  tickerFundCategories;

  fundManagers = []

  /**
   * @param {number} investmentAmount - The amount to be invested.
   * @param {Object.<string, number>} fundAllocation - A mapping of fund to the percentage allocated to the fund.
   * @param {RawStockData} rawStockData - Historical stock data.
   */
  constructor(investmentAmount, fundAllocation, rawStockData, tickerFundCategories) {
    this.investmentAmount = investmentAmount;
    this.fundAllocation = fundAllocation;
    this.rawStockData = rawStockData;
    this.tickerFundCategories = tickerFundCategories

    this.computeStockReturns()
  }

  computeStockReturns() {
    const fundManagers = []
    for (const [fund, allocation] of Object.entries(this.fundAllocation)) {
      const investmentAmount = Math.floor(this.investmentAmount * (allocation/100))
      if (investmentAmount < 1) { continue }
      fundManagers.push(new FundManager(investmentAmount, this.rawStockData[fund], this.tickerFundCategories[fund]))
    }

    this.fundManagers = fundManagers;
  }

  getEarliestYearForAllFunds() {
    // this is the earliest date for all funds
    // we have earliest date for A, B, C
    // do we want the highest or the least?
    let earliest = null;
    for (const fundManager of this.fundManagers) {
      if (!earliest) {
        earliest = fundManager.earliestYear
      } else {
        if (fundManager.earliestYear > earliest) {
          earliest = fundManager.earliestYear
        }
      }
    }
    return earliest
  }

  makeChartData() {
    const earliestYear = this.getEarliestYearForAllFunds()
    // not all stocks have data going back 20 years so we have to only 
    // use stock data starting from a particular threshold
    const chartRows = []
    const currentYear = new Date().getFullYear();
    let year = +earliestYear

    while(year <= currentYear) {
      let totalReturnsForYear = 0
      const chartData = {
        year: year,
        date: new Date(year, 0, 1),
        bondMarketFunds: 0,
        internationalStockFunds: 0,
        stockMarketFunds: 0
      }
      for (const fundManager of this.fundManagers) {
        const fundReturns = Math.floor(fundManager.getReturnsForYear(year))
        const fundCategory = fundManager.getFundCategory()

        if (!isNaN(fundReturns)) {
          chartData[fundCategory] = fundReturns
          totalReturnsForYear += fundReturns
        }
      }
      chartData.value = Math.floor(totalReturnsForYear)
      chartRows.push(chartData)
      year += 1;
    }
    return chartRows;
  }

  getFinalValue(chartData) {
    return chartData[chartData.length - 1].value
  }

  getProfitOrLoss(chartData) {
    return this.getFinalValue(chartData) - this.investmentAmount
  }

  getPercentageReturn (value, previousValue) {
    if (previousValue - 1 === 0) { return 0 }
    return (value / previousValue - 1) * 100;
  };

  calculateDownSideDeviationAndRiskLevelFromChartData(chartData) {
    const percentageReturns = chartData.map((row, rowIndex, chartData) => {
      const previousValue = chartData[rowIndex - 1]?.value ?? this.investmentAmount;
      return this.getPercentageReturn(row.value, previousValue);
    });
  
    const squaredPercentageReturnsBelowTarget = percentageReturns.map(
      (percentageReturn) => {
        if (percentageReturn < DOWNSIDE_DEVIATION_TARGET) {
          return Math.pow(percentageReturn, 2);
        }
        return 0;
      }
    );
  
    const sumOfSquaredPercentageReturnsBelowTarget =
      squaredPercentageReturnsBelowTarget.reduce(
        (sum, squaredPercentageReturnBelowTarget) =>
          sum + squaredPercentageReturnBelowTarget,
        0
      );
  
    const downsideDeviation = Math.sqrt(
      sumOfSquaredPercentageReturnsBelowTarget / chartData.length
    );
  
    const riskLevel = this.getRiskLevel(downsideDeviation);
    return { downsideDeviation, riskLevel }
  }

  calculateDrawDown(chartData) {
    let lastPeakValue = 0;
    let maximumDrawdownValue = 0;
    let maximumDrawdownPercentage = 0;
    chartData.forEach((row) => {
      if (row.value > lastPeakValue) {
        lastPeakValue = row.value;
      }
      if (lastPeakValue - row.value > maximumDrawdownValue) {
        maximumDrawdownValue = lastPeakValue - row.value;
        maximumDrawdownPercentage = (maximumDrawdownValue / lastPeakValue) * 100;
      }
    });
    return { maximumDrawdownValue, maximumDrawdownPercentage }
  }

  getRiskLevel(downsideDeviation) {
    for (const riskLevel of Object.values(RiskLevel)) {
      const maxDownsideDeviation =
        riskLevelConfig[riskLevel].maxDownsideDeviation;
      if (
        maxDownsideDeviation === null ||
        downsideDeviation <= maxDownsideDeviation
      ) {
        return riskLevel;
      }
    }
    return RiskLevel.HIGH;
  };
}


class FundManager {

  /**
  * @type {[]AssetRowDto}
  */
  stockData;

  /**
  * @type {number}
  */
   investmentAmount;

  /**
  * @type {Object.<number, []number>}
  */
  annualReturns = {};

  /**
  * @type {string}
  */
  fundCategory

  earliestYear = null

   /**
   * @param {number} investmentAmount - The amount to be invested.
   * @param {[]AssetRowDto} stockData - Historical stock data.
   * @param {string} fundCategory - Type of fund - bond, stock, int'l bond?
   */
   constructor(startingInvestment, stockData, fundCategory) {
    this.startingInvestment = startingInvestment;
    this.stockData = stockData;
    this.fundCategory = fundCategory

    this.computeInvestmentReturns()
  }

  getFundCategory() {
    return this.fundCategory
  }

  computeInvestmentReturns() {
    if (this.startingInvestment === 0 || this.stockData.length === 0) { return }

    // the first stock data is assumed to be the time you bought the shares
    // this was sorted in descending order - sorting just for sanity
    this.stockData.sort((a, b) => a.year - b.year);
    const pricePerShare = this.stockData[0].price;
    // number of shares is fixed at the beginning based on our first stock data
    const shares = this.startingInvestment / pricePerShare;

    for (const stockInformation of this.stockData) {
      const year = stockInformation.year
      const valueOfShares = Math.floor(shares * parseFloat(stockInformation.price));

      this.updateEarliestYear(year)
      this.annualReturns[year] = valueOfShares
    }

  }

  getReturnsForYear(year) {
    return this.annualReturns[year]
  }

  updateEarliestYear(year) {
    if (!this.earliestYear) {
      this.earliestYear = year
    } else if (year < this.earliestYear) {
      this.earliestYear = year
    }
  }
}