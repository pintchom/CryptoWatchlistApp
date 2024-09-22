//
//  DataModel.swift
//  CryptoTrackerTest2
//
//  Created by Max Pintchouk on 9/19/24.
//

import Foundation
import SwiftData

// refresh each token
// Get new token

@Model
class DataModel: Codable, Identifiable {
    
    enum CodingKeys: CodingKey {
        case id, symbol, current_price, market_cap_rank
    }
    
    var id: String
    var symbol: String
    var current_price: Double
    var market_cap_rank: Int
    var color: String = "GREEN"
    
    init(id: String, symbol: String, current_price: Double, market_cap_rank: Int) {
        self.id = id
        self.symbol = symbol
        self.current_price = current_price
        self.market_cap_rank = market_cap_rank
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        symbol = try container.decode(String.self, forKey: .symbol)
        current_price = try container.decode(Double.self, forKey: .current_price)
        market_cap_rank = try container.decode(Int.self, forKey: .market_cap_rank)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(current_price, forKey: .current_price)
        try container.encode(market_cap_rank, forKey: .market_cap_rank)
    }
    
    func refresh() async {
        let data = await fetchNewToken(name: self.id.lowercased())
        switch data {
        case.success(let value):
            self.color = value.current_price < self.current_price ? "RED" : "GREEN"
            self.current_price = value.current_price
            self.market_cap_rank = value.market_cap_rank
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

struct FailedFetch: Codable {
    var status: Status
    struct Status: Codable {
        var error_code: Int
        var error_message: String
    }
}

func fetchNewToken(name: String) async -> Result<DataModel, Error> {
    let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(name)")!
    print(url)
    do {
        let (data, _ ) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode([DataModel].self, from: data)
        if decoded.count > 0 {
            return .success(decoded[0])
        } else {
            throw APIError.BadTicker
        }
    } catch {
        do {
            let (data, _ ) = try await URLSession.shared.data(from: url)
            let caughterror = try JSONDecoder().decode(FailedFetch.self, from: data)
            print(caughterror)
        } catch {
            print("Does not match failure struct")
        }
        return .failure(error)
    }
}

enum APIError: Error {
    case BadTicker
}
