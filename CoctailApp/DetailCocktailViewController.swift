//
//  DetailCocktailsViewCintroller.swift
//  CoctailApp
//
//  Created by Виталик Молоков on 14.03.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: - Properties
    
    var cocktail: Cocktail?
    
    //MARK: - UI Elements
    
    private lazy var nameCocktails: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = cocktail?.name
        return label
    }()
    
    private lazy var ingredientsCocktails: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Ingredients:\n" + (cocktail?.ingredients.joined(separator: "\n") ?? "")
        return label
    }()
    
    private lazy var instructionCocktails: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "Instructions:\n" + (cocktail?.instructions ?? "")
        return label
    }()
    
    private lazy var cocktailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .lightGray // Заглушка, пока изображение загружается
        return imageView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierrachy()
        setupLayouts()
        
        if let cocktailName = cocktail?.name {
            CocktailAPIManager.shared.fetchCocktailImageUrl(for: cocktailName) { [weak self] imageUrlString in
                guard let imageUrlString = imageUrlString, let imageUrl = URL(string: imageUrlString) else {
                    return
                }
                self?.loadImage(from: imageUrl)
            }
        }
    }
    
    //MARK: - Setups
    
    private func setupHierrachy() {
        view.addSubview(nameCocktails)
        view.addSubview(ingredientsCocktails)
        view.addSubview(instructionCocktails)
        view.addSubview(cocktailImageView)
    }
    
    private func setupLayouts() {
        cocktailImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(400)
        }

        nameCocktails.snp.makeConstraints { make in
            make.top.equalTo(cocktailImageView.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
        }

        ingredientsCocktails.snp.makeConstraints { make in
            make.top.equalTo(nameCocktails.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
        }

        instructionCocktails.snp.makeConstraints { make in
            make.top.equalTo(ingredientsCocktails.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self?.cocktailImageView.image = image
            }
        }.resume()
    }
}
