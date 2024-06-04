const mongoose = require("mongoose");

const portfolioSchema = new mongoose.Schema({
  Ticker: {
    type: String,
    required: true,
  },
  Name: {
    type: String,
    required: true,
  },
  Qty: {
    type: Number,
    required: true,
  },
  AvgPrice: {
    type: Number,
    required: true,
  },
});

module.exports = mongoose.model("portfolio", portfolioSchema);
