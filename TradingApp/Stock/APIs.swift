//
//  APIs.swift
//  Stock
//
//  Created by Aarya Devnani on 29/04/24.
//

import Foundation
import SwiftyJSON
import Alamofire

// MARK: - CashBalance
func fetchCashBalance() async throws -> Double {
    let urlString = "http://localhost:8080/api/wallet"
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable(JSON.self).value
    return response["response"]["Amount"].doubleValue
}

// MARK: - Portfolio

struct PortfolioItem: Identifiable, Codable {
    var id: String
    var avgPrice: Double
    var ticker: String
    var name: String
    var qty: Int

    static let empty = PortfolioItem(id: "", avgPrice: 0.00, ticker: "", name:"", qty:0);
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case avgPrice = "AvgPrice"
        case ticker = "Ticker"
        case name = "Name"
        case qty = "Qty"
    }
}

func fetchPortfolio()async throws -> [PortfolioItem] {
    let urlString = "http://localhost:8080/api/portfolio";
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable([PortfolioItem].self).value
    return response
}

// MARK: - Favourites

struct FavouritesItem : Identifiable, Codable {
    let ticker: String
    let name: String
    let id: String
    
    static let empty = FavouritesItem(ticker: "", name:"",id: "" );
    
    private enum CodingKeys : String, CodingKey {
        case ticker = "Ticker"
        case name = "Name"
        case id = "_id"
        
    }
}

func fetchFavourites()async throws -> [FavouritesItem] {
    let urlString = "http://localhost:8080/api/watchlist";
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable([FavouritesItem].self).value
    return response
}

func deleteFavourite(ticker: String) {
    let urlString = "http://localhost:8080/api/watchlist/"+ticker;
    _ = AF.request(urlString, method:.delete).response { response in
        switch response.result {
        case .success(_):
            print("favourite item deleted successfully");
        case .failure(let error):
            print("Failed to delte favourites item: \(error)");
        }
    }
}
func addFavourite(ticker: String, name: String) {
    let parameters: [String: String] = [
        "ticker":ticker,
        "name":name
    ]
        
        let urlString = "http://localhost:8080/api/watchlist/";
        _ = AF.request(urlString, method:.post, parameters:parameters, encoding:
                        JSONEncoding.default).response { response in
            switch response.result {
            case .success(_):
                print("favourite item added successfully");
            case .failure(let error):
                print("Failed to add favourites item: \(error)");
            }
    }
}
// MARK: - Quote

struct Quote:  Codable {
    let c, d, dp, h: Double
    let l, o, pc: Double
    let t: Int
    
    static let empty = Quote(c: 0.00, d: 0.00, dp: 0.00, h:0.00, l: 0.00, o: 0.00, pc:0.00, t:0);
}

func fetchQuote(ticker: String)async throws -> Quote {
    let urlString = "http://localhost:8080/api/quote/" + ticker;
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable(Quote.self).value
    return response
}

// MARK: - SearchResults

struct SearchResult: Codable{
    let symbol, description: String
}

func fetchSearchResults(ticker: String)async throws ->[SearchResult]{
    let urlString = "http://localhost:8080/api/search/"+ticker
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable([SearchResult].self).value
    return response
}

// MARK: - Company Profile

struct Profile: Codable {
    let country, currency, estimateCurrency, exchange: String
    let finnhubIndustry, ipo: String
    let logo: String
    let marketCapitalization: Double
    let name, phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
    static let empty = Profile(country: "", currency: "", estimateCurrency: "", exchange: "", finnhubIndustry: "", ipo: "", logo: "", marketCapitalization: 0.00, name: "", phone: "", shareOutstanding: 0.00, ticker: "", weburl: "")
}

func fetchProfile(ticker: String)async throws ->Profile{
    let urlString = "http://localhost:8080/api/profile/"+ticker
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable(Profile.self).value
    return response
}


//MARK: - Buy / Sell
func buy(ticker: String, name:String, qty: Int, avgPrice: Double){
    let parameters: [String: Any] = [
        "Ticker":ticker,
        "Name":name,
        "Qty":qty,
        "AvgPrice":avgPrice
    ]
    let urlString = "http://localhost:8080/api/portfolio/buy";
    _ = AF.request(urlString, method:.post, parameters:parameters, encoding:
                    JSONEncoding.default).response { response in
        switch response.result {
        case .success(_):
            print("Bought item successfully");
        case .failure(let error):
            print("Failed to Buy item: \(error)");
        }
    }
}

func sell(ticker: String, qty: Int, currPrice: Double){
    let parameters: [String: Any] = [
        "Ticker":ticker,
        "Qty":qty,
        "currPrice":currPrice
    ]
    let urlString = "http://localhost:8080/api/portfolio/sell";
    _ = AF.request(urlString, method:.post, parameters:parameters, encoding:
                    JSONEncoding.default).response { response in
        switch response.result {
        case .success(_):
            print("Sold item successfully");
        case .failure(let error):
            print("Failed to sell item: \(error)");
        }
    }
}


//MARK: NewsData:
struct News: Codable {
    let category, headline, image, related, source, summary, url: String
    var datetime, id: Int
    
    static let empty = News(category: "", headline: "", image: "", related: "", source: "", summary: "", url: "", datetime: 0, id: 0)
}

func fetchNewsData(ticker: String) async throws -> [News] {
    let urlString = "http://localhost:8080/api/news/\(ticker)"
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable([News].self).value
    return response
}

//MARK: Peers:
func fetchPeers(ticker: String) async throws -> [String]{
    let urlString = "http://localhost:8080/api/peers/" + ticker
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable([String].self).value
    return response
}

//MARK: Sentiments:
struct Sentiments: Codable {
    let symbol: String
    let positiveMsprSum: Double
    let negativeMsprSum: Double
    let totalMsprSum: Double
    let positiveChangeSum: Double
    let negativeChangeSum: Double
    let totalChangeSum: Double
}
func fetchSentiments(ticker: String) async throws -> Sentiments {
    let urlString = "http://localhost:8080/api/sentiments/" + ticker
    let request = AF.request(urlString)
    let response = try await request.serializingDecodable(Sentiments.self).value
    return response
}

import Foundation

public class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    public init(delay: TimeInterval) {
        self.delay = delay
    }

    /// Trigger the action after some delay
    public func run(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}
