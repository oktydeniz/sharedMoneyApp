//
//  PaymentDetailViewController.swift
//  sharemoney
//
//  Created by oktay on 2.12.2024.
//

import UIKit
import RealmSwift

class PaymentDetailViewController: UIViewController {
    
    var selectedPayment:Payment?
    var selectedActivity: Activity?
    
    let db = try! Realm()
    @IBOutlet weak var fee: UITextField!
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var personName: UITextField!
    
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    @IBAction func updateAction(_ sender: Any) {
        if let payment = selectedPayment {
            do {
                try db.write {
                    payment.desc = desc.text!
                    payment.userPayment = personName.text!
                    let quantitiy = fee.text ?? "0"
                    payment.quantitiy = Int(quantitiy) ?? -1
                }
            }catch {
                print("\(error.localizedDescription)")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func setUI(){
        personName.text = selectedPayment?.userPayment ?? "Uknown"
        fee.text = "\(String(describing: selectedPayment!.quantitiy))"
        desc.text = selectedPayment?.desc
        
        activityNameLabel.text = selectedActivity?.Name
        let total = selectedActivity?.payments.filter("userPayment == %@", selectedPayment!.userPayment).sum(ofProperty: "quantitiy") ?? 0
        paymentLabel.text = "\(total)"
    }
}
