export const formatMoney = (amount) => new Intl.NumberFormat('en-US').format(amount.toFixed(2))
