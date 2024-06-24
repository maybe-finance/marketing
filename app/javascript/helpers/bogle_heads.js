/**
 * @typedef {Object} AssetRowDto
 * @property {string} date
 * @property {number} open
 * @property {number} high
 * @property {number} low
 * @property {number} close
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
 * This is handles the computations for the
 * bogle heads growth calculator. The calculation of the
 * following are of particular note
 * - Generation of chart data.
 *   - computes final value of a porfiolio at the end of 
 *   - each year for the past 25 years.
 * - Calculating Percentage Returns Total
 * - Calculating final value of investment
 * - computing risk level and associated values for 
 *   - Downside Deviation
 *   - Maximum drawdown percentage
 * 
 * - Type declarations here are supposed to be documentary and to help us reason about the computations
 */
export default class BoggleHeads {
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
      const investmentAmount = this.investmentAmount * (allocation/100)
      if (investmentAmount < 1) { continue }
      fundManagers.push(new FundManager(investmentAmount, this.rawStockData[fund], this.tickerFundCategories[fund]))
    }

    this.fundManagers = fundManagers;
  }

  getEarliestDateForAllFunds() {
    // this is the earliest date for all funds
    // we have earliest date for A, B, C
    // do we want the highest or the least?
    let earliest = null;
    for (const fundManager of this.fundManagers) {
      if (!earliest) {
        earliest = fundManager.earliestDate
      } else {
        if (fundManager.earliestDate > earliest) {
          earliest = fundManager.earliestDate
        }
      }
    }
    return earliest
  }

  makeChartData() {
    const earliestDate = this.getEarliestDateForAllFunds()
    // not all stocks have data going back 20 years so we have to only 
    // use stock data starting from a particular threshold
    const chartRows = []
    const currentYear = new Date().getFullYear();
    let year = new Date(earliestDate).getFullYear();

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
  stockReturnsGroupedByYear = {};

  /**
  * @type {Object.<string, number>}
  */
  annualReturns = {}

  /**
  * @type {string}
  */
  fundCategory

  earliestDate = null

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
    this.stockData.sort((a, b) => new Date(a.datetime) - new Date(b.datetime));
    
    const pricePerShare = this.stockData[0].close;
    // number of shares is fixed at the beginning based on our first stock data
    const shares = this.startingInvestment / pricePerShare;
    // TODO: account for when the first stock is not valid?

    for (const stockInformation of this.stockData) {
      const valueOfShares = Math.floor(shares * parseFloat(stockInformation.close));
      const year = new Date(stockInformation.datetime).getFullYear()
      this.updateEarliestDate(stockInformation.datetime)
      this.updateStockReturns(year, valueOfShares)
    }

    this.summarizeInvestmentByYear()
  }

  summarizeInvestmentByYear() {
    const years = Object.keys(this.stockReturnsGroupedByYear).sort()

    const annualReturns = {}
    for (const year of years) {
      const returns = this.stockReturnsGroupedByYear[year]
      if (!returns || !returns.length) { continue }
      annualReturns[year] = returns[returns.length - 1]
    }
    this.annualReturns = annualReturns
    return annualReturns
  }

  getReturnsForYear(year) {
    return this.annualReturns[year]
  }

  updateEarliestDate(date) {
    if (!this.earliestDate) {
      this.earliestDate = date
    } else if (date < this.earliestDate) {
      this.earliestDate = date
    }
  }

  updateStockReturns(year, investmentReturns) {
    if (this.stockReturnsGroupedByYear[year]) {
      this.stockReturnsGroupedByYear[year].push(investmentReturns)
    } else {
      this.stockReturnsGroupedByYear[year] = [investmentReturns]
    }
  }
}