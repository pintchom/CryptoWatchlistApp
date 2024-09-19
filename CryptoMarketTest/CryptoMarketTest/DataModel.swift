//
//  DataModel.swift
//  CryptoMarketTest
//
//  Created by Max Pintchouk on 9/19/24.
//

import SwiftData
import Foundation

@Model
class DataModel: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case symbol
        case image
        case current_price
    }
    
    var symbol: String // TICKER
    var id: String // FULL NAME
    var image: String
    var current_price: Double
    var changeColor: String = "GREEN"
    init(symbol: String, id: String, image: String, current_price: Double) {
        self.symbol = symbol
        self.id = id
        self.image = image
        self.current_price = current_price
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        id = try container.decode(String.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        current_price = try container.decode(Double.self, forKey: .current_price)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(id, forKey: .id)
        try container.encode(image, forKey: .image)
        try container.encode(current_price, forKey: .current_price)
    }
}


func fetchData(name: String) async -> DataModel? {
    let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(name.lowercased())")!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let gatheredData = try JSONDecoder().decode([DataModel].self, from: data)
        if gatheredData.count > 0 {
            return gatheredData[0]
        } else {
            throw MyError.runtimeError("BAD TICKER")
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

enum MyError: Error {
    case runtimeError(String)
}
