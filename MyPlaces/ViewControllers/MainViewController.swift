//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Вадим Игнатенко on 12.10.22.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascedingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }

    // MARK: - Table view data source

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }

    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.lacationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.cosmosView.rating = place.rating
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        return cell
    }
    
    
    // MARK: table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
       return [deleteAction]
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    
    @IBAction func unwindSegue (_ segue: UIStoryboardSegue) {
        
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
      sorting()
    }
    
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascedingSorting.toggle()
        
        if ascedingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "icons8-сортировка-по-возрастанию-80")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "icons8-сортировка-по-убыванию-80")
        }
        sorting()
    }
    
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascedingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascedingSorting)
        }
        tableView.reloadData()
    }
}





extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
    
}
