//
//  SingleStock.swift
//  Stock
//
//  Created by Aarya Devnani on 20/04/24.
//

import SwiftUI



struct SingleStock: View {
    let ticker: String
    @Binding var portfolio: [PortfolioItem]
    @Binding var favourites: [FavouritesItem]
    @Binding var cashBalance: Double
    
    @State private var inPortfolio: Bool = false
    @State private var inFavourites: Bool = false
    @State private var graphCol: String = "#000000"
    @State private var color = Color(.gray)
    @State private var dirImage = "minus";
    @State private var quote: Quote?
    @State private var loading: Bool = true
    @State private var profile: Profile?
    @State private var peers: [String]?
    
    @State private var showToast = false
    @State private var message = ""
    

    func fetchSingleStockData() async {
        do{
            self.loading = true
            self.quote = try await fetchQuote(ticker: ticker)
            self.profile = try await fetchProfile(ticker: ticker)
            self.peers = try await fetchPeers(ticker: ticker)
            if(self.quote?.dp ?? 0.00 > 0){
                self.graphCol = "#60BA62"
                self.color = Color(.green)
                self.dirImage = "arrow.up.right"
            }else if(self.quote?.dp ?? 0.00 < 0){
                self.graphCol = "#ff0000"
                self.color = Color(.red)
                self.dirImage = "arrow.down.right"
            }
            
            for fav in favourites{
                if (fav.ticker == ticker){
                    self.inFavourites = true
                }
            }
            for item in portfolio{
                if (item.ticker == ticker){
                    self.inPortfolio = true
                }
            }
            self.loading = false
        }catch{
            self.loading = false
            print(error)
        }
    }
    //MARK: Main View
    var body: some View {
        ZStack{
            if(loading){
                Loading()
            }else{
            ScrollView{
    
                aboveCharts(ticker: ticker,quote:quote,profile:profile,graphCol:graphCol, color: color, dirImage: dirImage)
                
                //MARK: Charts
                    TabView {
                        HourlyChartView(ticker: ticker, color: graphCol).tabItem {
                            Label("Hourly", systemImage: "chart.xyaxis.line")
                        }
                        HistoricalChartView(ticker: ticker)
                            .tabItem {
                                Label("Historical", systemImage: "clock")
                            }
                    }.frame(height: 410).onAppear {
                        // Set UITabBar appearance here
                        UITabBar.appearance().isTranslucent = false
                        
                    }
                
                portfolioView(portfolio: $portfolio, inPortfolio: false, quote: quote ?? Quote.empty, ticker: ticker, profile: profile ?? Profile.empty, cashBalance: $cashBalance)
                
                statsView(quote: quote ?? Quote.empty)
                
                aboutView(profile: profile ?? Profile.empty, ticker: ticker, portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance, peers: peers ?? [""] ).padding()
                
                InsightsView(ticker: ticker, name: profile?.name ?? "")
                
                RecommendationChartView(ticker: ticker).frame(minHeight: 400)
                
                EarningsChartView(ticker: ticker).frame(minHeight: 400)
                
                NewsView(ticker: ticker)
                            }.toolbar{
                if(inFavourites){
                    Button {
                        deleteFavourite(ticker: ticker)
                        self.inFavourites = false;
                        self.showToast = true;
                        self.message = "Removing \(ticker) from favourites"
                        if let index = favourites.firstIndex(where: { $0.ticker == ticker }) {
                            favourites.remove(at: index)
                        }

                    } label: {
                        Image(systemName: "plus.circle.fill").imageScale(.large).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }else{
                    Button {
                        addFavourite(ticker:ticker, name:profile?.name ?? "")
                        self.inFavourites = true;
                        self.showToast = true;
                        self.message = "Adding \(ticker) to favourites"
                        favourites.append(FavouritesItem(ticker:ticker, name:profile?.name ?? "",id:"0"))
                    } label: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }
                
                
            }
        }
    }.overlay(
        Toast(message:message, isShowing: $showToast )
    ).task{
        await fetchSingleStockData()
    }
        
    }
}

struct aboveCharts: View {
    let ticker: String
    let quote: Quote?
    let profile: Profile?
    let graphCol: String
    let color: Color
    let dirImage: String
    var body: some View{
        VStack{
            VStack{
                HStack{
                    Text(profile?.name ?? "").foregroundStyle(Color(.gray)).padding(.top)
                    Spacer()
                    AsyncImage(url: URL(string: profile?.logo ?? "")){ result in
                        result.image?
                            .resizable()
                            .scaledToFill().clipShape(.rect(cornerRadius: 15))
                    }
                    .frame(width: 50, height: 50).padding(.trailing)
                }.padding(.leading)
                    HStack{
                        Text("$\(quote?.c ?? 0.00, specifier: "%.2f")").font(.largeTitle).bold()
                        Image(systemName: dirImage).imageScale(.large).foregroundColor(color)
                        Text("$\(quote?.d ?? 0.00, specifier: "%.2f")").font(.title2).foregroundColor(color)
                        Text("(\(quote?.dp ?? 0.00, specifier: "%.2f")%)").font(.title2).foregroundColor(color)
                        Spacer()
                    }.padding()
                Spacer()
            }.navigationTitle(ticker)
        }

    }
}
struct portfolioView: View{
    
    @Binding var portfolio: [PortfolioItem]
    @State var inPortfolio: Bool
   
    let quote: Quote
    let ticker: String
    let profile: Profile
    @Binding var cashBalance: Double
//    @State var index = -1
////    @State var changeInPrice: Double = 0.00

    
   
    

    var portfolioItem: PortfolioItem{
        for item in portfolio{
           
            if item.ticker == ticker{
                DispatchQueue.main.async{
                    self.inPortfolio = true
                    print(inPortfolio)
                }
                return item
            }
        }
        self.inPortfolio = false
        return PortfolioItem.empty
    }
    
    var changeInPrice: Double {
        return (quote.c - portfolioItem.avgPrice)*Double(portfolioItem.qty)
    }
    
    var body: some View{
        var changeCol: Color {
            if (changeInPrice > 0.00){
                return .green
            }else if(changeInPrice < 0.00){
                return .red
            }else{
                return .gray
            }
        }
        HStack {
            VStack{
                HStack{
                    Text("Portfolio").font(.title)
                    Spacer()
                }.padding()
                if(!(inPortfolio)){
                    HStack{
                        VStack(alignment: .leading){
                            Text("You have 0 shares of \(ticker).").font(.callout).lineLimit(1)
                            Text("Start Trading!").font(.callout)
                        }
                        Spacer()
                    }.padding(.leading)
                }else{
                
                HStack{
                    Text("Shares Owned: ").font(.callout).bold().padding(.leading)
                    Text("\(portfolioItem.qty)").font(.callout)
                    Spacer()
                }
                HStack{
                    Text("Avg. Cost / Share:").font(.callout).bold().padding(.leading).lineLimit(1)
                    Text("$\(portfolioItem.avgPrice, specifier: "%.2f")").font(.callout)
                    Spacer()
                }.padding(.top)
                HStack{
                    Text("Total Cost:").font(.callout).bold().padding(.leading)
                    Text("$\(portfolioItem.avgPrice*Double(portfolioItem.qty), specifier: "%.2f")").font(.callout)
                    Spacer()
                }.padding(.top)
                HStack{
                    Text("Change:").font(.callout).bold().padding(.leading)
                    Text("$\(changeInPrice, specifier: "%.2f")").font(.callout).foregroundColor(changeCol)
                    Spacer()
                }.padding(.top)
                HStack{
                    Text("Market Value:").font(.callout).bold().padding(.leading)
                    Text("$\(quote.c * Double(portfolioItem.qty), specifier: "%.2f")").font(.callout).foregroundColor(changeCol)
                    Spacer()
                }.padding(.top)
            }
            }
            TradeSheetView(inPortfolio: $inPortfolio, portfolio: $portfolio, name: profile.name, walletAmount: $cashBalance, ticker: ticker, portfolioItem: portfolioItem)
        }
        
    }
}

struct statsView: View{
    let quote: Quote
    var body: some View{
        VStack{
            HStack{
                Text("Stats").font(.title)
                Spacer()
            }.padding()
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Text("High Price:").bold()
                        Text("$\(quote.h, specifier: "%.2f")")
                    }.padding(.bottom)
                    HStack{
                        Text("Low Price:").bold()
                        Text("$\(quote.l, specifier: "%.2f")")
                    }
                    
                }.padding(.leading)
                Spacer()
                VStack(alignment: .leading){
                    HStack{
                        Text("Open Price:").bold()
                        Text("$\(quote.o, specifier: "%.2f")")
                    }.padding(.bottom)
                    HStack{
                        Text("Prev. Close:").bold()
                        Text("$\(quote.pc, specifier: "%.2f")")
                    }
                }.padding(.trailing)
                Spacer()
            }
        }
    }
}

struct aboutView: View{
    let profile: Profile
    let ticker: String
    @Binding var portfolio: [PortfolioItem]
    @Binding var favourites: [FavouritesItem]
    @Binding var cashBalance: Double
    let peers: [String]
    
    var body: some View{
        VStack{
            HStack{
                Text("About").font(.title)
                Spacer()
            }.padding()
            HStack {
                VStack(alignment: .leading){
                    HStack{
                        Text("IPO Start Date:").bold().font(.callout)
                    }
                    HStack{
                        Text("Industry:").bold().font(.callout)
                    }.padding([.top], 5)
                    HStack{
                        Text("Webpage:").bold().font(.callout)
                    }.padding([.top], 5)
                    HStack{
                        Text("Company Peers:").bold().font(.callout)
                    }.padding([.top], 5)
                }
                Spacer()
                VStack(alignment: .leading){
                    HStack{
                        Text("\(profile.ipo)").font(.callout)
                    }
                    HStack{
                        Text("\(profile.finnhubIndustry)").font(.callout)
                    }.padding([.top], 5)
                    HStack{
                        Link("\(profile.weburl)", destination: URL(string: profile.weburl)!).font(.callout)
                            .lineLimit(1)
                    }.padding([.top], 5)
                    HStack{
                        PeersListView(ticker: ticker, portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance, peers: peers)
                    }.padding([.top], 5)
                }
            }
        }
    }
}

#Preview("SingleStock Full") {
    NavigationView{
        @State var portfolioItem = PortfolioItem(id:"1", avgPrice:123.00, ticker:"AAPL", name: "Apple Inc.", qty:3);
        
        @State var quote = Quote(c: 173.5, d:4.2,dp:2.488, h: 176.03, l:173.12,o:173.39,pc:169.3, t:1714420801)
        
        @State var portfolio = [Stock.PortfolioItem(id: "66262253ec5e05aee42f98f2", avgPrice: 165.0, ticker: "AAPL", name: "Apple Inc", qty: 10), Stock.PortfolioItem(id: "6626227aec5e05aee42f9900", avgPrice: 713.65, ticker: "SMCI", name: "Super Micro Computer Inc", qty: 10)]
        @State var favourites = [FavouritesItem(ticker:"AAPL",name:"Apple Inc.", id:"1")]
        @State var cashBalance = 25000.00
        
        SingleStock(ticker: "AAPL", portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance)
//        portfolioView(portfolio: $portfolio, inPortfolio: false, quote: quote, ticker: "AAPL", profile: Profile.empty, cashBalance: $cashBalance)
        
    }
   
}




