//
//  FavoritesViewController.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    // MARK: - Variables and IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    var favorites = [Contact]()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFavorites()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func registerCells() {
        let nib = UINib(nibName: "ContactCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactCell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func loadFavorites() {
        if let favoritesObject = RealmManager.shared.getObjectsWith(type: Favorites.self)?.first as? Favorites {
            self.favorites = favoritesObject.contacts.map{$0}
            self.tableView.reloadData()
        }
    }
    
}

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        let contact = favorites[indexPath.row]
        contactCell.configureFor(contact: contact)
        contactCell.favoriteButton.isHidden = true
        
        return contactCell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            
            let contact = self.favorites[indexPath.row]
            if let favoritesObject = RealmManager.shared.getObjectsWith(type: Favorites.self)?.first as? Favorites {
                if let index = favoritesObject.contacts.index(where: {$0.email == contact.email}) {
                    try! RealmManager.shared.realm.write({
                        favoritesObject.contacts.remove(at: index)
                    })
                }
                RealmManager.shared.save(object: favoritesObject, update: true)
                
                self.favorites.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction]
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

