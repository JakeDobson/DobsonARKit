//
//  PlacesTableViewController.swift
//  coreLocation
//
//  Created by Josh Dobson on 2/2/18.
//  Copyright © 2018 Josh Dobson. All rights reserved.
//

import UIKit

class PlacesTableViewController : UITableViewController {
    
    private let places = ["Coffee", "Bars", "Fast Food", "Banks", "Hospitals", "Gas Stations"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = (self.tableView.indexPathForSelectedRow)!
        let place = self.places[indexPath.row]
        
        let vc = segue.destination as! ViewController
        vc.place = place
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.places[indexPath.row]
        return cell
    }
}
