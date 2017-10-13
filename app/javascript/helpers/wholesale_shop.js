export function price_text (price) {
  return "￥" + (price / 100).toFixed(2);
}
