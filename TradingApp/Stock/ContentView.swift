//
//  ContentView.swift
//  StockApp
//
//  Created by Aarya Devnani on 07/04/24.
//


import SwiftUI
import Alamofire
import SwiftyJSON

// MARK: - Global Constants
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd, yyyy"
    return formatter
}()



// MARK: - ContentView
struct ContentView: View {
    @State private var searchText = ""
    @State private var cashBalance = 0.00
    @State private var portfolio: [PortfolioItem] = []
    @State var favourites: [FavouritesItem] = []
    @State var quotes: [String: Quote] = [:]
    @State var loading = true
    @State var searchResults: [SearchResult] = []
    let debouncer = Debouncer(delay: 0.5)
    @Environment(\.isSearching) private var isSearching


    
    func fetchData() async {
        do {
            self.loading = true
            self.cashBalance = try await fetchCashBalance()
            self.portfolio = try await fetchPortfolio()
            self.favourites = try await fetchFavourites()

            var uniqueTickers = Set(portfolio.map { $0.ticker })
            uniqueTickers.formUnion(favourites.map { $0.ticker })

            for ticker in uniqueTickers {
                    do {
                        let quote = try await fetchQuote(ticker: ticker)
                        self.quotes[ticker] = quote
                    } catch {
                        print("Error fetching quote for \(ticker): \(error)")
                    }
                }
            self.loading = false
        } catch {
            self.loading = false
            print("Error fetching data: \(error)")
        }
    }
    var body: some View {
        
        VStack {
            NavigationStack {
                VStack{
                    
                   
                    if !loading || searchText != ""{
                        MainStockView(searchText: searchText, cashBalance: $cashBalance, portfolio: $portfolio, favourites: $favourites, quotes: quotes,searchResults: searchResults)
                        
                            
                            .searchable(text: $searchText, prompt: "Search").onChange(of: searchText){
                                Task {
                                    if(searchText.count > 2){
                                        searchResults = try await fetchSearchResults(ticker: searchText)
                                    }
                                }
                                if searchText.isEmpty && !isSearching {
                                    //Search cancelled here
                                    self.searchResults = []
                                    print(portfolio)
                                }
                                
                            }
                    } else if loading{
                        Loading()
                    }
                    
                }.navigationTitle("Stocks").task {
                    await fetchData()
                    print("Hello")
                }.toolbar{
                    EditButton()
                }
            }
            }
            .background(Color(red: 0.949, green: 0.949, blue: 0.97, opacity: 1.0))
            .edgesIgnoringSafeArea(.bottom)
        }
    
}

//MARK: - Loading View

struct Loading: View{
    var body: some View {
        VStack{
            ProgressView()
            Text("Fetching Data")
        }
    }
}


// MARK: - Main Stock View
struct MainStockView: View{
    @State var searchText: String
    @Binding var cashBalance: Double
    @Binding var portfolio: [PortfolioItem]
    @Binding var favourites: [FavouritesItem]
    let quotes: [String: Quote]
    let searchResults: [SearchResult]
    @Environment(\.isSearching) private var isSearching
    

    
    var body: some View{
            List {
                if !isSearching && searchText == ""{
                    
                    
                    // Header Section
                    HStack {
                        Text(dateFormatter.string(from: Date())).font(.largeTitle).bold().foregroundStyle(Color(.gray))
                        Spacer()
                    }
                    
                    // Portfolio Section
                    PortfolioSection(cashBalance: $cashBalance, portfolio: $portfolio, quotes: quotes, favourites: $favourites)
                    
                    // Favorites Section
                    FavoritesSection(favourites: $favourites, quotes: quotes, portfolio: portfolio, cashBalance: cashBalance)
                    
                    // Powered by Finnhub.io Link
                    Link(destination: URL(string: "https://finnhub.io")!) {
                        HStack {
                            Spacer()
                            Text("Powered by Finnhub.io").foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }else{
                    SearchedView(searchResults: searchResults, quotes:quotes, portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance, searchText: $searchText)
                }
            }.accentColor(.clear)

    }
}


// MARK: - Searched View

struct SearchedView: View {
    let searchResults: [SearchResult]
    let quotes: [String : Quote]
    @Binding var portfolio: [PortfolioItem]
    @Binding var favourites: [FavouritesItem]
    @Binding var cashBalance : Double
    @Binding var searchText: String
    var body: some View{
        if(searchText == ""){
        ForEach(searchResults, id: \.symbol){ searchResult in
            NavigationLink(destination: SingleStock(ticker: searchResult.symbol, portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance)){
                VStack(alignment: .leading) {
                    Text(searchResult.symbol)
                        .font(.title2)
                        .bold()
                    Text(searchResult.description)
                        .font(.callout)
                }
            }
        }
    }
    }
}

// MARK: - Portfolio Section
struct PortfolioSection: View {
    @Binding var cashBalance: Double
    @Binding var portfolio: [PortfolioItem]
    let quotes: [String: Quote]
    @Binding var favourites: [FavouritesItem]
    
    var netWorth: Double {
            var totalNetWorth = 0.0
            for item in portfolio {
                totalNetWorth += (quotes[item.ticker]?.c ?? 0) * Double(item.qty)
            }
            print(portfolio)
            return totalNetWorth + cashBalance
        }
    
    var body: some View {
        Section(header: Text("PORTFOLIO")) {
            HStack{
                VStack{
                    HStack {
                        Text("Net Worth").font(.title2)
                        Spacer()
                    }
                    HStack {
                        Text("\(netWorth, specifier: "%.2f")").font(.title2).bold()
                        Spacer()
                    }
                }
                VStack{
                    HStack {
                        Text("Cash Balance").font(.title2)
                    }
                    HStack {
                        Text("$\(cashBalance, specifier: "%.2f")").font(.title2).bold()
                    }
                }
            }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in return (-20)
            }
            
            ForEach($portfolio) { $item in
                NavigationLink(destination: SingleStock(ticker: item.ticker, portfolio: $portfolio, favourites: $favourites,cashBalance: $cashBalance)){
                    StockItemView(item: $item, quote: quotes[item.ticker] ?? Quote.empty)
                }
            }
            .onMove(perform: move)
        }
    }


    private func move(from source: IndexSet, to destination: Int) {
        print("Move function")
    }
}

// MARK: - Portfolio Summary Row
struct PortfolioSummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).font(.title2)
            Spacer()
            Text(value).font(.title2).bold()
        }
    }
}

// MARK: - StockItemView
struct StockItemView: View {
    @Binding var item: PortfolioItem
    let quote : Quote
    
    var changeInPrice: Double {
        print(item)
        return (quote.c - item.avgPrice)*Double(item.qty)
    }
    
    var changePercent: Double{
        let change = changeInPrice;
        let originalCost = item.avgPrice * Double(item.qty)
        
        return (change/originalCost)*100
    }
    
    var imageDir: String{
        if(changeInPrice > 0.00){
            return "arrow.up.right"
        }else if (changeInPrice < 0.00){
            return "arrow.down.right"
        }else{
            return "minus"
        }
    }
    
    var color: Color{
        if(changeInPrice > 0.00){
            return .green
        }else if (changeInPrice < 0.00){
            return .red
        }else{
            return .gray
        }
    }
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.ticker)
                    .font(.title2)
                    .bold()
                Text("\(item.qty) Shares")
                    .font(.callout)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("$\(quote.c * Double(item.qty), specifier: "%.2f")")
                    .font(.title2)
                    .bold()
                    HStack {
                        Image(systemName: imageDir)
                            .imageScale(.large)
                            .foregroundColor(color)
                        Text("$\(changeInPrice , specifier: "%.2f") (\(changePercent , specifier: "%.2f")%)")
                            .font(.title2)
                            .foregroundColor(color)
                    }
            }
        }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in return (120)
        }
    }
}

// MARK: - Favorites Section
struct FavoritesSection: View {
    @Binding var favourites: [FavouritesItem]
    let quotes: [String: Quote]
    @State var portfolio: [PortfolioItem]
    @State var cashBalance : Double
    
    var body: some View {
        Section(header: Text("FAVORITES")) {
            ForEach($favourites) { $item in
                NavigationLink(destination: SingleStock(ticker: item.ticker, portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance)){
                    FavoriteStockRow(item: item,quote: quotes[item.ticker] ?? Quote.empty)
                }
            }
            .onDelete(perform: delete)
            .onMove{favourites.move(fromOffsets: $0, toOffset: $1)}
        }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in return (120)
        }
    }

    private func delete(at offsets: IndexSet) {
        let indicesToRemove = Array(offsets)
        let index = indicesToRemove[0]
        let ticker = favourites[index].ticker
        favourites.remove(at: index)
        let url = "http://localhost:8080/api/watchlist/\(ticker)"
        AF.request(url, method: .delete).response { response in
            switch response.result {
            case .success(_):
                print("Watchlist item deleted successfully")
            case .failure(let error):
                print("Failed to delete watchlist item: \(error)")
            }
        }
    
    }

    private func move(from source: IndexSet, to destination: Int) {
        print("Move function")
    }
}

// MARK: - FavoriteStockRow
struct FavoriteStockRow: View {
    let item: FavouritesItem
    let quote : Quote
    
    var imageDir: String{
        if(quote.dp > 0.00){
            return "arrow.up.right"
        }else if (quote.dp < 0.00){
            return "arrow.down.right"
        }else{
            return "minus"
        }
    }
    
    var color: Color{
        if(quote.dp > 0.00){
            return .green
        }else if (quote.dp < 0.00){
            return .red
        }else{
            return .gray
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.ticker)
                    .font(.title2)
                    .bold()
                Text(item.name)
                    .font(.callout)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("$\(quote.c, specifier: "%.2f" )")
                    .font(.title2)
                    .bold()
                
                    HStack {
                        Image(systemName: imageDir)
                            .imageScale(.large)
                            .foregroundColor(color)
                        Text("$\(quote.d , specifier: "%.2f") (\(quote.dp , specifier: "%.2f")%)")
                            .font(.title2)
                            .foregroundColor(color)
                    }
                
                
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
