const mongoose = require("mongoose");

const walletSchema = new mongoose.Schema({
  Amount: {
    type: Number,
    required: true,
  },
});

module.exports = mongoose.model("wallet", walletSchema);
