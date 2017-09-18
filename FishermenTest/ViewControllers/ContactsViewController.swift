//
//  ContactsViewController.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import UIKit
import ICSPullToRefresh

class ContactsViewController: UIViewController {
    // MARK: - Variables and IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl = UIRefreshControl()
    var contacts = [Contact]()
    var searchActive = false
    var filteredContacts = [Contact]()
    var currentPage = 0
    var currentSeed = ""
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        registerCells()
        setupSearchBar()
        
        loadContacts()
        
        self.currentPage = 1
        tableView.addInfiniteScrollingWithHandler {
            DispatchQueue.global(qos: .userInitiated).async {
                Contacts.getContactsWith(seed: self.currentSeed, page: self.currentPage, pageSize: 20) { (result, info, error) in
                    if error == nil {
                        if let result = result {
                            if result.contacts.count == 0 {
                                self.tableView.infiniteScrollingView?.stopAnimating()
                                self.tableView.setShowsInfiniteScrolling(false)
                                return
                            }
                            let contactList = result.contacts.map { $0 }
                            self.contacts.append(contentsOf: contactList)
                            
                            if self.searchActive {
                                self.filteredContacts = self.contacts.filter({
                                    $0.firstname.localizedCaseInsensitiveContains(self.searchBar.text!) || $0.lastname.localizedCaseInsensitiveContains(self.searchBar.text!) || $0.email.localizedCaseInsensitiveContains(self.searchBar.text!)
                                })
                            }
                            self.currentPage += 1
                        }
                    }
                    DispatchQueue.main.async { [unowned self] in
                        self.tableView.reloadData()
                        self.tableView.infiniteScrollingView?.stopAnimating()
                    }
                }
            }
        }
        tableView.infiniteScrollingView?.setActivityIndicatorColor(UIColor.black)
        tableView.setShowsInfiniteScrolling(true)
        
        refreshControl.addTarget(self, action: #selector(refreshContactList), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func setupSearchBar() {
        self.searchBar.placeholder = "Search via name, email"
    }
    
    func registerCells() {
        let nib = UINib(nibName: "ContactCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactCell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func loadContacts() {
        Contacts.getContacts { (result, info, error) in
            if error == nil {
                if let result = result {
                    self.contacts = result.contacts.map { $0 }
                    
                    if self.searchActive {
                        self.filteredContacts = self.contacts.filter({
                            $0.firstname.localizedCaseInsensitiveContains(self.searchBar.text!) || $0.lastname.localizedCaseInsensitiveContains(self.searchBar.text!) || $0.email.localizedCaseInsensitiveContains(self.searchBar.text!)
                        })
                    }
                    self.currentSeed = (info?.seed)!
                    self.currentPage += 1
                }
            }
            else {
                let alert = UIAlertController(title: "", message: error?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshContactList() {
        self.currentPage = 1
        loadContacts()
    }
    
}

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return filteredContacts.count
        }
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        var contact: Contact
        if(searchActive) {
            contact = filteredContacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        contactCell.configureFor(contact: contact)
        
        return contactCell
    }
    
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ContactsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterContentForSearchText(searchText: searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchText)
    }
    
    func filterContentForSearchText(searchText: String) {
        if searchText == "" {
            searchActive = false
            self.tableView.reloadData()
            return
        }
        
        self.filteredContacts = self.contacts.filter({
            $0.firstname.localizedCaseInsensitiveContains(searchText) || $0.lastname.localizedCaseInsensitiveContains(searchText) || $0.email.localizedCaseInsensitiveContains(searchText)
        })
        self.searchActive = true
        self.tableView.reloadData()
    }
}



