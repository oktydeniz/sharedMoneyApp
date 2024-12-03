//
//  ActivitiesTableViewController.swift
//  sharemoney
//
//  Created by oktay on 28.11.2024.
//

import UIKit
import RealmSwift

class ActivitiesTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var plusButton: UIBarButtonItem!
    var events: Results<Activity>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        searchBar.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "activityCell")
        
        let allPayments = events?[indexPath.row].payments.sum(ofProperty: "quantitiy") ?? 0
        if let name = events?[indexPath.row].Name {
            cell.textLabel?.text = "\(name) - \(allPayments)"
        }else {
            cell.textLabel?.text = "Uknown"
        }
        
        if events?[indexPath.row].isFinish ?? false {
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.white
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "payment_page_segue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "payment_page_segue" {
            let destination = segue.destination as! PaymentsListViewController
            if let selectedIndex = tableView.indexPathForSelectedRow {
                destination.selectedEvent = events?[selectedIndex.row]
            }
        }
    }
    
    @IBAction func addNewAction(_ sender: Any) {
        let alert = UIAlertController(title: "Add New", message:"Add new activity", preferredStyle: .alert)
        alert.addTextField { txt in
            txt.placeholder = "Name"
        }
        let action = UIAlertAction(title: "Add", style: .default) {a in
            let textActivityName  = alert.textFields![0]
            if !textActivityName.text!.isEmpty {
                let newOne = Activity()
                newOne.Name = textActivityName.text!
                self.getData(activity: newOne)
                self.tableView.reloadData()
            }
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getData(activity: Activity) {
        do {
            try realm.write {
                realm.add(activity)
            }
        }catch {
            print("\(error)")
        }
    }
    
    func loadData(){
        events = realm.objects(Activity.self)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        events = events?.filter("Name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "Name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0) {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // Close Keyboard
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Delete"){ (action, indexPath) in
            if let selected = self.events?[indexPath.row]{
                do {
                    try self.realm.write{
                        self.realm.delete(selected.payments)
                        self.realm.delete(selected)
                    }
                }catch {
                    print("\(error.localizedDescription)")
                }
            }
            tableView.reloadData()
        }
        
        
        let makeEqual = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Make Equal"){ (action, indexPath) in
            if let selected = self.events?[indexPath.row] {
                do {
                    try self.realm.write{
                        selected.isFinish = true
                    }
                }catch {
                    print("\(error.localizedDescription)")
                }
            }
            tableView.reloadData()
        }
        delete.backgroundColor = .red
        makeEqual.backgroundColor = .systemGreen
        return [makeEqual, delete]
    }
}
