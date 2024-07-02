/**
 * @typedef {Object} AssetRowDto
 * @property {string} date
 * @property {string} ticker
 * @property {number} year
 * @property {number} month
 * @property {number} price
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
   * mapping of fund ticker to percentage allocation
   * the percentage is yet to be applied.
   */
  fundAllocation;

  /**
   * @type {RawStockData}
   */
  rawStockData;

  
  tickerFundCategories;

  /**
   * @type {[]FundManager}
   * These are used to manage funds
   * - compute their earnings
   * - store number of shares purchased
   */
  fundManagers = [];

  /**
   * @type {string}
   */
  portfolioStartDate

    /**
   * @type {string}
   */
    portfolioEndDate

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

    this.getPortfolioStartDate();

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
          this.tickerFundCategories[fund],
          this.portfolioStartDate
        )
      );
    }

    this.fundManagers = fundManagers;
  }

  getPortfolioStartDate() {
    const earliestDates = Object.values(this.rawStockData).map(this.getEarliestStockDataForFund)
    let earliest = earliestDates[0];
    
    for (const earliestDate of earliestDates) {
      if (earliestDate > earliest) {
        earliest = earliestDate;
      }
    }
    this.portfolioStartDate = earliest;
  }

  getPortfolioEndDate() {
    const latestDates = Object.values(this.rawStockData).map(this.getLatestStockDataForFund)
    let latest = latestDates[0];
    
    for (const latestDate of latestDates) {
      if (latestDate > latest) {
        latest = latestDate;
      }
    }
    this.portfolioEndDate = latest;
    return latest;
  }

  getEarliestStockDataForFund(stockDataForFund) {
    let earliestDate = null;
    for (const stockInformation of stockDataForFund) {
      const date = stockInformation.date;
      if (!earliestDate) {
        earliestDate = date;
      } else if (date < earliestDate) {
        earliestDate = date;
      }
    }
    return earliestDate;
  }

  getLatestStockDataForFund(stockDataForFund) {
    let latestDate = null;
    for (const stockInformation of stockDataForFund) {
      const date = stockInformation.date;
      if (!latestDate) {
        latestDate = date;
      } else if (date > latestDate) {
        latestDate = date;
      }
    }
    return latestDate;
  }

  makeChartData() {
    const earliestDate = new Date(this.portfolioStartDate);
    const earliestYear = earliestDate.getFullYear();
    const earliestMonth = earliestDate.getMonth() + 1;

    const latestDate = new Date(this.getPortfolioEndDate())
    const latestYear = latestDate.getFullYear();
    const latestMonth = earliestDate.getMonth() + 1;

    const chartRows = [];
    let year = earliestYear;

    while (year <= latestYear) {
      let month = earliestMonth
      while (month <= latestMonth) {
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

  getCurrentMarketValue(chartData) {
    return chartData[chartData.length - 1].value
  }

  getProfitOrLoss(chartData) {
    return this.getCurrentMarketValue(chartData) - this.investmentAmount
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
  startingInvestment;

  /**
   * @type {Object.<string, number>}
   */
  annualReturns = {};

  /**
   * @type {string}
  */
  fundCategory;

  /**
   * @type float
   * actual number of shares bought
   * We chose not to round this because of the slight differences in the computed portfolio value
   * This reflects the domain where the actual investment amount may not fit into exact number
   * of shares across a portfolio so in real life even if you allocate $150, 000 for investment in
   * funds A, B, C - you may only end up with shares worth 149,831 based on the price per share.
  */
  numberOfSharesBought

  /**
   * @type string
   * starting date to buy shares
  */
  portfolioStartDate = null;

  constructor(startingInvestment, stockData, fundCategory, portfolioStartDate) {
    this.startingInvestment = startingInvestment;
    this.stockData = stockData;
    this.fundCategory = fundCategory;
    this.portfolioStartDate = portfolioStartDate;

    this.buyShares()
  }

  buyShares() {
    const sharePriceOnEarliestStockDate = this.getSharePriceOn(this.portfolioStartDate)
    this.numberOfSharesBought = this.startingInvestment / sharePriceOnEarliestStockDate
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

  computeEarningsFor(year, month) {
    const stockData = this.getStockDataFor(year, month);
    const earnings = stockData.price * this.numberOfSharesBought;
    return [stockData.date, earnings];
  }
}
