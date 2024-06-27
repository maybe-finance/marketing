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

const MONTH_NAMES = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

const DOWNSIDE_DEVIATION_TARGET = 0;

const RiskLevel = {
  LOW: "Low",
  MODERATE: "Moderate",
  HIGH: "High",
};

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

  fundManagers = [];

  /**
   * @param {number} investmentAmount - The amount to be invested.
   * @param {Object.<string, number>} fundAllocation - A mapping of fund to the percentage allocated to the fund.
   * @param {RawStockData} rawStockData - Historical stock data.
   */
  constructor(
    investmentAmount,
    fundAllocation,
    rawStockData,
    tickerFundCategories
  ) {
    this.investmentAmount = investmentAmount;
    this.fundAllocation = fundAllocation;
    this.rawStockData = rawStockData;
    this.tickerFundCategories = tickerFundCategories;

    this.allocateFundsToFundManagers();
  }

  allocateFundsToFundManagers() {
    const fundManagers = [];
    for (const [fund, allocation] of Object.entries(this.fundAllocation)) {
      const investmentAmount = this.investmentAmount * (allocation / 100);
      if (investmentAmount < 1) {
        continue;
      }
      fundManagers.push(
        new FundManager(
          investmentAmount,
          this.rawStockData[fund],
          this.tickerFundCategories[fund]
        )
      );
    }

    this.fundManagers = fundManagers;
  }

  getEarliestDateForAllFunds() {
    // this is the earliest date for all funds
    // we have earliest date for A, B, C
    // do we want the highest or the least?
    let earliest = null;
    for (const fundManager of this.fundManagers) {
      const fundEarliestStockDate = fundManager.computeEarliestStockDate();
      if (!earliest) {
        earliest = fundEarliestStockDate;
      } else {
        if (fundEarliestStockDate > earliest) {
          earliest = fundEarliestStockDate;
        }
      }
    }
    return earliest;
  }

  makeChartData() {
    const earliestDate = new Date(this.getEarliestDateForAllFunds());
    const earliestYear = earliestDate.getFullYear();
    const earliestMonth = earliestDate.getMonth() + 1;
    // get earliest date.
    // use it to compute earnings on that date for each.


    // not all stocks have data going back 20 years so we have to only
    // use stock data starting from a particular threshold
    const chartRows = [];
    const currentYear = new Date().getFullYear();
    let year = earliestYear;

    console.log("getEarliestDateForAllFunds", this.getEarliestDateForAllFunds())

    while (year <= currentYear) {
      // we need to iterate over stock data for that year as well
      // and compute the total returns for that year
      const targetMonth = year === currentYear ? new Date().getMonth() + 1 : 12;
      let month = earliestMonth
      while (month <= targetMonth) {
        // compute earnings for that month
        // const date = new Date(year, tickerDate.getMonth() + 1, 1);
        const chartData = {
          yearMonth: `${MONTH_NAMES[month - 1]} ${year}`,
          year,
          month,
          bondMarketFunds: 0,
          internationalStockFunds: 0,
          stockMarketFunds: 0,
        };
        let totalEarnings = 0;
        for (const fundManager of this.fundManagers) {
          const [date, earnings] = fundManager.computeEarningsFor(year, month);
          const fundCategory = fundManager.getFundCategory();

          console.log("fundCategory", fundCategory, date, earnings)

          chartData[fundCategory] = earnings;
          totalEarnings += earnings;
          chartData.date = date
        }
        chartData.value = totalEarnings
        chartRows.push(chartData);
        month += 1
      }
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

  getPercentageReturn(value, previousValue) {
    if (previousValue - 1 === 0) {
      return 0;
    }
    return (value / previousValue - 1) * 100;
  }

  calculateDownSideDeviationAndRiskLevelFromChartData(chartData) {
    const percentageReturns = chartData.map((row, rowIndex, chartData) => {
      const previousValue =
        chartData[rowIndex - 1]?.value ?? this.investmentAmount;
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
    return { downsideDeviation, riskLevel };
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
        maximumDrawdownPercentage =
          (maximumDrawdownValue / lastPeakValue) * 100;
      }
    });
    return { maximumDrawdownValue, maximumDrawdownPercentage };
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
  }
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
  annualReturns = {};

  /**
   * @type {string}
   */
  fundCategory;

  numberOfSharesBought

  earliestDate = null;

  /**
   * @param {number} investmentAmount - The amount to be invested.
   * @param {[]AssetRowDto} stockData - Historical stock data.
   * @param {string} fundCategory - Type of fund - bond, stock, int'l bond?
   */
  constructor(startingInvestment, stockData, fundCategory) {
    this.startingInvestment = startingInvestment;
    this.stockData = stockData;
    this.fundCategory = fundCategory;

    // fund manager computes number of shares bought
    // sets earliest date along the line
    this.buyShares()
  }

  buyShares() {
    const earliestStockDate = this.computeEarliestStockDate()
    const sharePriceOnEarliestStockDate = this.getSharePriceOn(earliestStockDate)
    this.numberOfSharesBought = Math.floor(this.startingInvestment / sharePriceOnEarliestStockDate)
  }

  getFundCategory() {
    return this.fundCategory;
  }

  getSharePriceOn(date) {
    const stockInformation = this.stockData.find(
      (stockInformation) => stockInformation.date === date
    );
    if (stockInformation) {
        return stockInformation.price
    }
    
    // we guarantee this does not happen
    // as long as our computation for earliest common date is valid
    return 0
  }

  getStockDataFor(year, month) {
    console.log("STOCK", this.stockData[0], year, month)
    const stockInformation = this.stockData.find(
      (stockInformation) => stockInformation.year === year && stockInformation.month === month
    );
    if (stockInformation) {
        return stockInformation
    }
    
    // we guarantee this does not happen
    // as long as our computation for earliest common date is valid
    return 0
  }

  computeEarliestStockDate() {
    if (this.earliestDate) { return this.earliestDate }
    for (const stockInformation of this.stockData) {
      this.updateEarliestDate(stockInformation.date);
    }
    return this.earliestDate;
  }

  computeEarningsFor(year, month) {
    const stockData = this.getStockDataFor(year, month);
    console.log("this.numberOfSharesBought", this.numberOfSharesBought, stockData)
    const earnings = stockData.price * this.numberOfSharesBought;
    return [stockData.date, earnings];
  }

  getReturnsForYear(year) {
    return this.annualReturns[year];
  }

  updateEarliestDate(date) {
    if (!this.earliestDate) {
      this.earliestDate = date;
    } else if (date < this.earliestDate) {
      this.earliestDate = date;
    }
  }

  updateStockReturns(year, investmentReturns) {
    if (this.stockReturnsGroupedByYear[year]) {
      this.stockReturnsGroupedByYear[year].push(investmentReturns);
    } else {
      this.stockReturnsGroupedByYear[year] = [investmentReturns];
    }
  }
}
