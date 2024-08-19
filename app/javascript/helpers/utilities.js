import { TICKER_FULL_NAMES } from "helpers/constants"

export const formatMoney = (amount) => new Intl.NumberFormat('en-US').format(amount.toFixed(2))

export const getTickerName = (ticker) => TICKER_FULL_NAMES[ticker.toUpperCase()]
