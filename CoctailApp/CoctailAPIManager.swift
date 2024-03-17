//
//  CoctailAPIManager.swift
//  CoctailApp
//
//  Created by Виталик Молоков on 14.03.2024.
//

import Foundation

struct Cocktail: Decodable {
    let name: String
    let ingredients: [String]
    let instructions: String
    var imageUrl: String?
}

struct CocktailDetail: Decodable {
    let drinks: [CocktailInfo]
}

struct CocktailInfo: Decodable {
    let strDrinkThumb: String?
}


class CocktailAPIManager {
    static let shared = CocktailAPIManager()
    private let apiKey = "/uvauKUnexqBJoUUmKv4pg==sBsiGYbNuMaFSZhG"
    private let baseURL = "https://api.api-ninjas.com/v1/cocktail"
    
    func fetchCocktails(matching query: String, completion: @escaping ([Cocktail]?, Error?) -> Void) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?name=\(queryEncoded)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let cocktails = try decoder.decode([Cocktail].self, from: data)
                completion(cocktails, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func fetchCocktailImageUrl(for cocktailName: String, completion: @escaping (String?) -> Void) {
        let query = cocktailName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(query)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(CocktailDetail.self, from: data)
                let imageUrl = result.drinks.first?.strDrinkThumb // Используйте imageUrl напрямую, без добавления /preview
                completion(imageUrl)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
