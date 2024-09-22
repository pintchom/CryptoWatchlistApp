//
//  ContentView.swift
//  CryptoTrackerTest2
//
//  Created by Max Pintchouk on 9/19/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    struct Person: Identifiable {
        let givenName: String
        let familyName: String
        let emailAddress: String
        let id = UUID()
        var fullName: String { givenName + " " + familyName }
    }


    @State private var people = [
        Person(givenName: "Juan", familyName: "Chavez", emailAddress: "juanchavez@icloud.com"),
        Person(givenName: "Mei", familyName: "Chen", emailAddress: "meichen@icloud.com"),
        Person(givenName: "Tom", familyName: "Clark", emailAddress: "tomclark@icloud.com"),
        Person(givenName: "Gita", familyName: "Kumar", emailAddress: "gitakumar@icloud.com")
    ]
    
    @Environment(\.modelContext) private var context
    @Query private var data: [DataModel]
    @State private var newCoin: String = ""
    @State private var timeRemaining: Int = 30
    @State private var isEnabled: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let currencyStyle = Decimal.FormatStyle.Currency(code: "USD")

    var body: some View {
        VStack {
            Text("Seconds to next refresh: \(timeRemaining)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.green)
            Table(people) {
                TableColumn("", value: \.givenName)
                TableColumn("", value: \.familyName)
                TableColumn("", value: \.emailAddress)
            }
//            Table(data.sorted { $0.market_cap_rank < $1.market_cap_rank }) {
//                TableColumn("Token") { coin in
//                    Text(coin.id).border(.blue)
//                }
//                TableColumn("Ticker") { coin in
//                    Text(coin.symbol).border(.blue)
//                }
//                TableColumn("Price/USD") { coin in
//                    Text(Decimal.FormatStyle.Currency.FormatInput(coin.current_price), format: currencyStyle).border(.blue)
//                }
//                TableColumn("Rank") { coin in
//                    Text(String(coin.market_cap_rank)).border(.blue)
//                }
//            }
            .frame(width:350)
            .border(.blue)
            List {
                ForEach(data.sorted { $0.market_cap_rank < $1.market_cap_rank } , id:\.self) { coin in
                    HStack {
                        Text(coin.id)
                        Text("(\(coin.symbol))")
                        Spacer()
                        Text(String(coin.current_price))
                            .foregroundStyle(Color(coin.color))
                        Text(String(coin.market_cap_rank))
                    }
                }
            }
            .padding()
            Spacer()
            TextField("Enter a new coin", text: $newCoin)
                .padding()
            Button {
                Task {
                    let new = await fetchNewToken(name: newCoin.lowercased())
                    switch new {
                    case .success(let new):
                        for coin in data {
                            if coin.id == new.id {
                                print("Attempted to add duplicate coin")
                                return
                            }
                        }
                        context.insert(new)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    newCoin = ""
                }
            } label: {
                Text("Submit")
            }

        }
        .padding()
        .task {
            await refreshAll()
        }
        .onReceive(timer) { _ in
            timeRemaining -= 1
            isEnabled.toggle()
            if timeRemaining == 0 {
                Task {
                    await refreshAll()
                }
                isEnabled.toggle()
                timeRemaining = 30
            }
        }
    }
    func refreshAll() async {
        for coin in data {
            await coin.refresh()
            context.insert(coin)
        }
    }
}

#Preview {
    ContentView()
}
