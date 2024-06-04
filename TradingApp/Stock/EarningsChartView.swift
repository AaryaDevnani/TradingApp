//
//  EarningsChartView.swift
//  Stock
//
//  Created by Aarya Devnani on 01/05/24.
//

import SwiftUI

struct EarningsChartView: View {
    let ticker: String
    var body: some View {
        WebView(htmlString: """
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
      const fetchEarnings = async (ticker) => {
        const response = await fetch(`http://127.0.0.1:8080/api/earnings/${ticker}`);
        const resJson = await response.json();
        const actualSurpriseArray = [];
        const estimateSurpriseArray = [];
        const timeArr = [];

        resJson.forEach((item) => {
          timeArr.push(`${item.period} <br/> Surprise: ${item.surprise}`);
          actualSurpriseArray.push([item.period, item.actual]);
          estimateSurpriseArray.push([item.period, item.estimate]);
        });
        return {
          timeArr,
          actualSurpriseArray,
          estimateSurpriseArray,
        };
      };

      fetchEarnings("\(ticker)")
        .then((data) => {
          // Work with the parsed JSON data
          let earnings = data;
          let splineOptions = {
            chart: {
              height:400,
              type: "spline",
              backgroundColor: "#ffffff",
            },
            title: {
              text: "Historical EPS Surprises",
              align: "center",
            },
            xAxis: {
              categories: earnings.timeArr,
            },
            yAxis: {
              title: {
                text: "Quarterly EPS",
              },
            },
            legend: {
              enabled: true,
            },

            plotOptions: {
              spline: {
                marker: {
                  enable: false,
                },
              },
            },
            series: [
              {
                name: "Actual",
                data: earnings.actualSurpriseArray,
              },
              {
                name: "Estimate",
                data: earnings.estimateSurpriseArray,
              },
            ],
          };
          Highcharts.chart("container", splineOptions);
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
    EarningsChartView(ticker:"MSFT")
}
