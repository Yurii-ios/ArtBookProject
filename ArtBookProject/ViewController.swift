//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Yurii Sameliuk on 05/02/2020.
//  Copyright © 2020 Yurii Sameliuk. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    // sozdaem masiwu 4tobu zapisat w nix dannue s core data
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selestedPaintingId: UUID?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // sozdanie knopki w panele nawigacii swerxy sprawa pri pomos4i koda
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ViewController.addButton))
        
        getData()
        
    }
    // zdes mu bydem wuzuwat  NotificationCenter
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    // izwlekaem dannue
    @objc func getData() {
        
        // reshaem problemy pri kotoroj kopirowalis wse dannue a ne tolko nowue pri ispolzowanii " NotificationCenter"
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        //false - yskoriaet process poly4enija dannux s kesha , pri rabote s bolshim koli4estwom dannux
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let resaults = try context.fetch(fetchRequest)
            // esli masiw s dannumi ne pystoj
            if resaults.count > 0 {
                // resaults - iz tipa Any? priwodimk tipy [NSManagedObject]
                for resault in resaults as! [NSManagedObject]{
                    // poly4aem i sapisuwaem dannue w pystoj masiw
                    if let name = resault.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    // polu4aem id iz bazu dannux w nowuj masiw
                    if let id = resault.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
                
            }
        }catch {
            let nserror = error as NSError
            fatalError("\(nserror), \(nserror.userInfo)")
            
        }
    }
    
    @objc func addButton() {
        
        selectedPainting = ""
        
        performSegue(withIdentifier: "toDetailVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selestedPaintingId = idArray[indexPath.row]
        selectedPainting = nameArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selestedPaintingId 
        }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if  editingStyle == .delete {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idstring = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idstring)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let resaults = try context.fetch(fetchRequest)
                if resaults.count > 0 {
                    for resault in resaults as! [NSManagedObject]{
                        if let id = resault.value(forKey: "id") as? UUID {
                            // 4tobu but ywerenum w ydalenii togo 4to nam nado
                            if id == idArray[indexPath.row] {
                                context.delete(resault)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                tableView.reloadData()
                                do {
                               try context.save()
                                }catch {
                                    let nserror = error as NSError
                                    fatalError("\(nserror), \(nserror.userInfo)")
                                }
                                // nužno dlia togo 4tobu posle ydalenija 1 elementa mu wusli is cukla ydalenija
                                break
                            }
                            
                        }
                    }
                }
            }catch {
                let nserror = error as NSError
                fatalError("\(nserror), \(nserror.userInfo)")
            }
        }
        
    }
}

