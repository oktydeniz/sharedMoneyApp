//
//  PurchaseListViewController.swift
//  sharemoney
//
//  Created by oktay on 29.11.2024.
//

import UIKit
import RealmSwift

class PaymentsListViewController : UITableViewController, UISearchBarDelegate {

    let db = try! Realm()
    var payments: Results<Payment>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedEvent: Activity? {
        didSet {
            loadPayment()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "payment_cell", for: indexPath)
        if let payment = payments?[indexPath.row] {
            cell.textLabel?.text = "\(payment.userPayment) | \(payment.quantitiy)"
        }else {
            cell.textLabel?.text = "No Data Found"
        }
        return cell
    }
    @IBAction func addAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Payment", message: "Add New Payment", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { t in
            t.placeholder = "Person Name"
        }
        
        alertController.addTextField { t in
            t.placeholder = "Description"
        }
        
        alertController.addTextField { t in
            t.placeholder = "Fee"
            t.keyboardType = .numberPad
        }
        
        let add = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { a in
            let person = alertController.textFields![0].text ?? "None"
            let desc = alertController.textFields![1].text ?? "None"
            let fee = alertController.textFields![2].text ?? "-1"
            if let chosenActivity = self.selectedEvent {
                do {
                    try self.db.write {
                        let newPayment = Payment()
                        newPayment.userPayment = person
                        newPayment.desc = desc
                        newPayment.quantitiy = Int(fee)!
                        chosenActivity.payments.append(newPayment)
                    }
                }catch {
                    print("\(error.localizedDescription)")
                }
            }
            self.tableView.reloadData()
        }
        alertController.addAction(add)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func loadPayment() {
        payments = selectedEvent?.payments.sorted(byKeyPath: "userPayment", ascending: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "payment_detail_cell", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "payment_detail_cell" {
            let vc = segue.destination as! PaymentDetailViewController
            if let selectedIndex = tableView.indexPathForSelectedRow {
                if let payment = payments?[selectedIndex.row]{
                    vc.selectedPayment = payment
                    vc.selectedActivity = selectedEvent
                    vc.title = "\(payment.userPayment) Info"
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let selected = payments?[indexPath.row]{
                do {
                    try db.write{
                        db.delete(selected)
                    }
                }catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - SearchBar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(payments?.count == 0){
            loadPayment()
        }
        payments = payments?.filter("userPayment CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "userPayment", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0) {
            loadPayment()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // Close Keyboard
            }
        }
    }
}
