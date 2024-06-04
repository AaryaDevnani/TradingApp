//
//  ChartOneView.swift
//  Stock
//
//  Created by Aarya Devnani on 20/04/24.
//

import SwiftUI
import WebKit
struct HistoricalChartView: View {
    let ticker: String
    
    
    var body: some View {
        VStack{
            
            
            WebView(htmlString: """
<!DOCTYPE html>
                    <html>
                        <head>
                         <meta name="viewport" content="width=device-width, initial-scale=0.9, maximum-scale=.9, user-scalable=no">
        <style>
            body{
            display:flex;
            justify-content:center;
            }
            #container {
              max-width: 400px;
              max-height: 490px;
              width: 100%; /* Ensures the container takes up the available width */
              height: auto; /* Automatically adjusts the height to maintain aspect ratio */
            }
          </style>
            </head>
                <body>
                    
                <div id="container"></div>
                <script src="https://code.highcharts.com/stock/highstock.js"></script>
                <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
                <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
                <!-- <script src="https://code.highcharts.com/modules/accessibility.js"></script> -->
                <script>
                    const groupingUnits = [
                    ["week", [1]],
                    ["month", [1, 2, 3, 4, 6]],
                  ];
                    let fetchChartData = async ()=>{
                        const response = await fetch('http://127.0.0.1:8080/api/historical/\(ticker)');
                        const chartData = await response.json();
                        let data = chartData.results;
                        let arr1 = [];
                        let arr2 = [];
                        for (let i = 0; i < data.length; i += 1) {
                        arr1.push([
                            data[i].t, // the date
                            data[i].o, // open
                            data[i].h, // high
                            data[i].l, // low
                            data[i].c, // close
                        ]);

                        arr2.push([
                            data[i].t, // the date
                            data[i].v, // the volume
                        ]);
                        }
                        return {
                            ohlc: arr1,
                            volume: arr2
                        };
                        }
                    let data = fetchChartData().then(data => {
                        console.log(data);
                        let options = {
                            chart: {
                                height: 400,
                                backgroundColor: "#ffffff",
                            },
                            rangeSelector: {
                                allButtonsEnabled: true,
                                enabled: true,
                                selected: 2,
                            },
                            title: {
                                text: `\(ticker) Historical`,
                            },
                            subtitle: {
                                text: "With SMA and Volume by Price technical indicators",
                            },
                            navigator: {
                                enabled: true,
                            },
                            scrollbar: {
                                enabled: true,
                            },
                            credits: {
                                enabled: false,
                            },
                            xAxis: {
                                type: "datetime",
                                title: false,
                                ordinal: true,
                            },
                            yAxis: [
                                {
                                    opposite: true,
                                    startOnTick: false,
                                    endOnTick: false,
                                    labels: {
                                        align: "right",
                                        x: -3,
                                    },
                                    title: {
                                        text: "OHLC",
                                    },
                                    height: "60%",
                                    lineWidth: 2,
                                    resize: {
                                        enabled: true,
                                    },
                                },
                                {
                                    opposite: true,
                                    labels: {
                                        align: "right",
                                        x: -3,
                                    },
                                    title: {
                                        text: "Volume",
                                    },
                                    top: "65%",
                                    height: "35%",
                                    offset: 0,
                                    lineWidth: 2,
                                },
                            ],
                            
                            tooltip: {
                                split: true,
                            },
                            
                            plotOptions: {
                                series: {
                                    dataGrouping: {
                                        units: groupingUnits,
                                    },
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
                                    showInLegend: false,
                                    type: "candlestick",
                                    name: `AAPL`,
                                    id: "aapl",
                                    zIndex: 2,
                                    data: data.ohlc,
                                },
                                {
                                    showInLegend: false,
                                    type: "column",
                                    name: "Volume",
                                    id: "volume",
                                    data: data.volume,
                                    yAxis: 1,
                                },
                                {
                                    type: "vbp",
                                    linkedTo: "aapl",
                                    params: {
                                        volumeSeriesID: "volume",
                                    },
                                    dataLabels: {
                                        enabled: false,
                                    },
                                    zoneLines: {
                                        enabled: false,
                                    },
                                },
                                {
                                    type: "sma",
                                    linkedTo: "aapl",
                                    zIndex: 1,
                                    marker: {
                                        enabled: false,
                                    },
                                },
                            ],
                        };
                        Highcharts.stockChart("container", options);
                    });
                    </script>
                </body>
                </html>

""")
        }
    }
}

#Preview {
    HistoricalChartView(ticker:"NVDA")
}
