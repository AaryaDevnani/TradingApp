//
//  RecommendationChartView.swift
//  Stock
//
//  Created by Aarya Devnani on 01/05/24.
//

import SwiftUI

struct RecommendationChartView: View {
    let ticker: String
    var body: some View {
        WebView(htmlString:"""
        <html>
          <head>
            <meta
              name="viewport"
              content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
            />
            <style>
              #container {
                max-width: 400px;
                max-height: 400px;
                width: 100%;
                height: auto;
              }
            </style>
          </head>
          <body>
            <div id="container"></div>
            <script>
            const fetchRecs = async (ticker) => {
                const response = await fetch(`http://127.0.0.1:8080/api/recommendations/${ticker}`);
                const resJson = await response.json();
                let strongSell = [];
                let sell = [];
                let hold = [];
                let buy = [];
                let strongBuy = [];
                let dates = [];
                resJson.map((item) => {
                strongBuy.push(item.strongBuy);
                buy.push(item.buy);
                hold.push(item.hold);
                sell.push(item.sell);
                strongSell.push(item.strongSell);
                dates.push(item.period);
                });
                let series = {
                strongBuy,
                buy,
                hold,
                sell,
                strongSell,
                dates,
                };
                return series;
            };

              fetchRecs("\(ticker)")
                .then((data) => {
                  // Work with the parsed JSON data
                  let recs = data;
                  const barOptions = {
                    chart: {
                      height: 400,
                      type: "column",
                      backgroundColor: "#ffffff",
                    },
                    title: {
                      text: "Recommendation Trends",
                      align: "center",
                    },
                    xAxis: {
                      categories: recs.dates,
                    },
                    yAxis: {
                      min: 0,
                      title: {
                        text: "#Analysis",
                      },
                      stackLabels: {
                        enabled: false,
                      },
                    },
                    plotOptions: {
                      column: {
                        stacking: "normal",
                        dataLabels: {
                          enabled: true,
                        },
                      },
                    },
                    series: [
                      {
                        name: "Strong Buy",
                        data: recs.strongBuy,
                        color: "#19703a",
                      },
                      {
                        name: "Buy",
                        data: recs.buy,
                        color: "#1BAD54",
                      },
                      {
                        name: "Hold",
                        data: recs.hold,
                        color: "#C19725",
                      },
                      {
                        name: "Sell",
                        data: recs.sell,
                        color: "#F06366",
                      },
                      {
                        name: "Strong Sell",
                        data: recs.strongSell,
                        color: "#8A3536",
                      },
                    ],
                  };

                  Highcharts.chart("container", barOptions);
                })
                .catch((error) => {
                  // Handle any errors that might occur during fetching, processing, or chart rendering
                  console.error("Error:", error);
                });
            </script>
            <script src="https://code.highcharts.com/highcharts.js"></script>
            <script src="https://code.highcharts.com/modules/exporting.js"></script>
            <script src="https://code.highcharts.com/modules/export-data.js"></script>
            <script src="https://code.highcharts.com/modules/accessibility.js"></script>
          </body>
        </html>

        """)
    }
}

#Preview {
    RecommendationChartView(ticker: "AAPL")
}
