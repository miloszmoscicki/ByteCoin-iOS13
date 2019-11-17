//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
protocol CoinManagerDelegate {
    func didUpdateCurrency(_ coinManager: CoinManager, _ coinModel: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    var currencyName: String?
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    mutating func getCoinPrice(for currency: String) {
        currencyName = currency
        let currencyURL = baseURL + currency
        performRequest(with: currencyURL)
        
        
    }
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error)
                }
                if let safeData = data {
                     if let currencyRates = self.parseJSON(safeData){
                        self.delegate?.didUpdateCurrency(self, currencyRates)
                    }
                }
            }
            task.resume()
    }
    
}
    func parseJSON (_ currencyData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            let rate = decodedData.last
            
            if let safeCurrency = currencyName{
    
                let coinModel = CoinModel(rate: rate, currency: safeCurrency)
                return coinModel
            }
        
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
        return nil
    }
}
