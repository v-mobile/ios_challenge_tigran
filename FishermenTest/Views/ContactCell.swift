//
//  ContactCell.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import UIKit
import AlamofireImage

class ContactCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var contact: Contact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureFor(contact: Contact) {
        self.contact = contact
        
        nameLabel.text = "\(contact.title) \(contact.firstname) \(contact.lastname)"
        nationalityLabel.text = contact.nationality
        phoneLabel.text = contact.phone
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        let date = formatter.date(from: contact.dob)
        
        formatter.dateFormat = "MMM d, yyyy"
        let dateString = formatter.string(from: date!)
        
        birthdayLabel.text = dateString
        
        guard let url = URL(string: contact.mediumImageUrl) else {
            return
        }
        
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: avatar.frame.size,
            radius: avatar.frame.size.width/2
        )
        avatar.af_setImage(withURL: url, placeholderImage: UIImage(), filter: filter)
        
        if let favoritesObject = RealmManager.shared.getObjectsWith(type: Favorites.self)?.first as? Favorites {
            if favoritesObject.contacts.contains(contact) {
                favoriteButton.isSelected = true
            }
            else {
                favoriteButton.isSelected = false
            }
        }
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        if !favoriteButton.isSelected {
            if let favoritesObject = RealmManager.shared.getObjectsWith(type: Favorites.self)?.first as? Favorites {
                try! RealmManager.shared.realm.write({
                    favoritesObject.contacts.append(self.contact!)
                })
                RealmManager.shared.save(object: favoritesObject, update: true)
            }
            else {
                let newObject = Favorites()
                newObject.id = "Favorites"
                newObject.contacts.append(self.contact!)
                RealmManager.shared.save(object: newObject, update: true)
            }
            self.favoriteButton.isSelected = true
        }
    }
}
