//
//  PeersListView.swift
//  Stock
//
//  Created by Aarya Devnani on 01/05/24.
//

import SwiftUI

struct PeersListView: View {
    let ticker: String
    @Binding var portfolio: [PortfolioItem]
    @Binding var favourites: [FavouritesItem]
    @Binding var cashBalance: Double
    @State var peers: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        
                        ForEach(peers.filter { !$0.contains(".") }, id: \.self) { peer in
                            NavigationLink(destination: SingleStock(ticker: peer, portfolio: $portfolio, favourites: $favourites, cashBalance: $cashBalance)) {
                                Text("\(peer), ")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
    }
}

//#Preview {
//    PeersListView()
//}
