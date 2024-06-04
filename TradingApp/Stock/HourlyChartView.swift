//
//  HourlyChartView.swift
//  Stock
//
//  Created by Aarya Devnani on 20/04/24.
//

import SwiftUI
import WebKit
struct HourlyChartView: View {
    let ticker: String
    let color: String
    
    
    var body: some View {
        VStack{
            
            
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
                width: 100%; /* Ensures the container takes up the available width */
                height: auto; /* Automatically adjusts the height to maintain aspect ratio */
              }
            </style>
          </head>
          <body>
            <div id="container"></div>
            <script>
              const fetchSingleDayStock = async (ticker) => {
                try {
                  const currQuote = await fetch(
                    `http://127.0.0.1:8080/api/quote/${ticker}`
                  );
                  const currQuoteJson = await currQuote.json();
                  console.log(currQuoteJson);

                  let currentDate = new Date(currQuoteJson.t * 1000);
                  let oneDayAgo = new Date(
                    currentDate.getTime() - 1 * 24 * 60 * 60 * 1000
                  );

                  const formatDate = (date) => {
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, "0");
                    const day = String(date.getDate()).padStart(2, "0");
                    return `${year}-${month}-${day}`;
                  };

                  const formattedCurrentDate = formatDate(currentDate);
                  const formattedOneDayAgo = formatDate(oneDayAgo);
                  console.log(formattedCurrentDate, formattedOneDayAgo);
                  const response = await fetch(
                    `http://localhost:8080/api/historical/${ticker}/${formattedOneDayAgo}/${formattedCurrentDate}`
                  );
                  const resJson = await response.json();
                  return resJson;
                } catch (error) {
                  console.error("Error fetching data:", error);
                  throw error; // Rethrow the error to be caught by the caller
                }
              };

              fetchSingleDayStock("\(ticker)")
                .then((data) => {
                  // Work with the parsed JSON data
                  let mappedData = data.results.map((item) => [
                    item.t,
                    item.o,
                  ]);

                  let options = {
                    chart: {
                      height: 350,
                      type: "line",
                      backgroundColor: "#ffffff",
                    },
                    title: {
                      text: `\(ticker) Hourly Price Variation`,
                      style: {
                        color: "#918f8e",
                      },
                    },
                    legend: {
                      enabled: false,
                    },
                    xAxis: {
                      type: "datetime",
                      labels: {
                        format: "{value:%H:%M}",
                      },
                      title: false,
                    },
                    yAxis: {
                      opposite: true,
                      title: false,
                    },
                    plotOptions: {
                      series: {
                        marker: {
                          enabled: false,
                          states: {
                            hover: {
                              enabled: false,
                            },
                          },
                        },
                      },
                    },
                    series: [
                      {
                        data: mappedData,
                        color: "\(color)",
                      },
                    ],
                  };

                  Highcharts.chart("container", options);
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
}

struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}



#Preview {
    HourlyChartView(ticker:"NVDA", color:"#198754")
}

