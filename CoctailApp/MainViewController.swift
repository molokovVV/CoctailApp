//
//  ViewController.swift
//  CoctailApp
//
//  Created by Виталик Молоков on 14.03.2024.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate {
    
    //MARK: - Properties
    
    var cocktails = [Cocktail]()
    
    //MARK: - UI Elements
    
    private lazy var searchResultCocktails: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none 
        return tableView
    }()
    
    private lazy var cocktailsSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default) // Установка прозрачного фона для searchBar
        return searchBar
    }()
    
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "Header")
        return imageView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayouts()
        setupDismissKeyboardGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCleanViewAfterSearch()
    }
    
    //MARK: - Setups
    
    private func setupHierarchy() {
        view.backgroundColor = .white
        view.addSubview(headerImageView)
        view.addSubview(cocktailsSearchBar)
        view.addSubview(searchResultCocktails)
    }
    
    private func setupLayouts() {
        headerImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.height.equalTo(150)
        }
        
        cocktailsSearchBar.snp.remakeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom)
            make.left.right.equalTo(view)
        }
        
        searchResultCocktails.snp.makeConstraints { make in
            make.top.equalTo(cocktailsSearchBar.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func setupCleanViewAfterSearch() {
        cocktailsSearchBar.text = ""
        cocktails = []
        searchResultCocktails.reloadData()
    }
    
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Actions
    
    @objc private func dismissKeyboard() {
        cocktailsSearchBar.resignFirstResponder()
    }
    
    //MARK: - Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            cocktails = []
            searchResultCocktails.reloadData()
        } else {
            CocktailAPIManager.shared.fetchCocktails(matching: searchText) { [weak self] cocktails, error in
                DispatchQueue.main.async {
                    if let cocktails = cocktails {
                        self?.cocktails = cocktails
                        self?.searchResultCocktails.reloadData()
                    } else if let error = error {
                        print("Error fetching cocktails: \(error)")
                    }
                }
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cocktails[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.cocktail = cocktails[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
