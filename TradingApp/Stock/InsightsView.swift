//
//  InsightsView.swift
//  Stock
//
//  Created by Aarya Devnani on 01/05/24.
//

import SwiftUI

struct InsightsView: View {
    let ticker: String
    let name: String
    @State var sentiments: Sentiments?
    var body: some View {
        VStack{
            HStack{
                Text("Insights").font(.title)
                Spacer()
            }.padding()
            
            HStack {
                VStack {
                    HStack {
                        Text("Insider Sentiments").font(.title)
                    }
                }
                }
            
            VStack(alignment:.leading) {
                HStack{
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(name)").fontWeight(.bold).font(.system(size: 14))
                                    Divider()
                                    Text("Total").fontWeight(.bold).font(.system(size: 14))
                                    Divider()
                                    Text("Positve").fontWeight(.bold).font(.system(size: 14))
                                    Divider()
                                    Text("Negative").fontWeight(.bold).font(.system(size: 14))
                                    Divider()
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("MSPR").fontWeight(.bold).font(.system(size: 14))
                                    Divider()
                                    Text("\(String(format: "%.2f",sentiments?.totalMsprSum ?? 0.00))").font(.system(size: 14))
                                    Divider()
                                    Text("\(String(format: "%.2f",sentiments?.positiveMsprSum ?? 0.00))").font(.system(size: 14))
                                    Divider()
                                    Text("\(String(format: "%.2f",sentiments?.negativeMsprSum ?? 0.00))").font(.system(size: 14))
                                    Divider()
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Change").fontWeight(.bold).font(.system(size: 14))
                                    Divider()
                                    Text("\(String(format: "%.2f",sentiments?.totalChangeSum ?? 0.00))").font(.system(size: 14))
                                    Divider()
                                    Text("\(String(format: "%.2f",sentiments?.positiveChangeSum ?? 0.00))").font(.system(size: 14))
                                    Divider()
                                    Text("\(String(format: "%.2f",sentiments?.negativeChangeSum ?? 0.00))").font(.system(size: 14))
                                    Divider()
                                }
                            }
            }.task {
                do{
                    self.sentiments = try await fetchSentiments(ticker: ticker)
                }catch{
                    print("Error")
                }
                
            }.padding()
        }
    }
}

//#Preview {
////    InsightsView()
//}
