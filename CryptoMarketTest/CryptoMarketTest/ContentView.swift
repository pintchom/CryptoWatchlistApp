//
//  ContentView.swift
//  CryptoMarketTest
//
//  Created by Max Pintchouk on 9/19/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var new: Bool = true
    @Query var data: [DataModel]
    @State private var newTicker: String = ""
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            List {
                ForEach(data, id: \.self) { coin in
                    HStack {
                        Text(coin.id)
                        Text("(\(coin.symbol))")
                        Spacer()
                        Text(String(coin.current_price))
                            .foregroundStyle(Color(coin.changeColor))
                    }
                }
            }
            .padding()
            
            TextField("Enter a symbol name", text: $newTicker)
            HStack {
                Button {
                    print()
                    Task {
                        if let coin: DataModel = await fetchData(name: newTicker) {
                            var exists: Bool = false
                            for x in data {
                                if x.id == coin.id {
                                    exists.toggle()
                                    print("TOKEN ALREADY EXISTS")
                                    break
                                }
                            }
                            if !exists {
                                modelContext.insert(coin)
                            }
                        } else {
                            print("BAD TICKER")
                        }
                    }
                } label: {
                    Text("Submit")
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button {
                    refresh()
                } label: {
                    Text("Force Refresh")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.leading, 50)
            .padding(.trailing, 50)
        }
        .onReceive(timer) { _ in
            print("Timer executed")
            refresh()
        }
        .task {
            refresh()
        }
    }
    func refresh() {
        print("REFRESHING")
        Task {
            for coin in data {
                print(coin.id)
                print(coin.symbol)
                guard let updated = await fetchData(name: coin.id) else {
                    print("failed fetch")
                    return
                }
                coin.changeColor = 5.0 < coin.current_price ? "RED" : "GREEN"
                coin.current_price = updated.current_price
                modelContext.insert(coin)
            }
        }
    }
}

#Preview {
    ContentView()
}
