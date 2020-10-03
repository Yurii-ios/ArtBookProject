//
//  DetailVC.swift
//  ArtBookProject
//
//  Created by Yurii Sameliuk on 06/02/2020.
//  Copyright © 2020 Yurii Sameliuk. All rights reserved.
//

import UIKit
import CoreData

class DetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var savebutton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId: UUID?
    // poly4aem dostup k baze dannux
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            savebutton.isHidden = true
            
                        //Core Data
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
            // UUID peredeluwaem w String format
            let idString = chosenPaintingId?.uuidString
            // poly4aem dannue iz bazu otsortirowanue po id
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
               let resaults = try context.fetch(fetchRequest)
                
                if resaults.count > 0 {
                    for resault in resaults as! [NSManagedObject] {
                        if let name = resault.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = resault.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = resault.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = resault.value(forKey: "image") as? Data {
                            userImage.image = UIImage(data: imageData)
                        }
                    }
                }
                
            }catch {
                let nserror = error as NSError
                fatalError("\(nserror), \(nserror.userInfo)")
            }
            

//            let stringUUID = chosenPaintingId?.uuidString
//            print(stringUUID)
            
        }else {
            savebutton.isHidden = false
            savebutton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        // delaem wozmožnum skrut klawiatyry kasaniem po ekrany
        let gestorRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // dobawliaem recognizer w view predstawlenie
        view.addGestureRecognizer(gestorRecognizer)
        
        // delaem image klikabelnum
        userImage.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        view.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        // poly4aem dostyp k interfejsy sjemki kameroj, takže dostyp do biblioteki polzowatelia
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    // srabatuwaet kogda mu wubrali foto s biblioteki
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        userImage.image = info[.originalImage] as? UIImage
        // knopka ne bydet aktiwnoj poka polzowatel ne wberet izobraženije
        savebutton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {

        // sozdaem ekzempliar nashego klasa bazu dannux
        let newPaimting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        // Attributes
        newPaimting.setValue(nameText.text!, forKey: "name")
        newPaimting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!) {
            newPaimting.setValue(year, forKey: "year")
        }
        newPaimting.setValue(UUID(), forKey: "id")
        // podgotawliwaem image dlia soshranenija w baze dannux
        let data = userImage.image?.jpegData(compressionQuality: 0.5)
        newPaimting.setValue(data, forKey: "image")
        
        
            do {
                try context.save()
                print("success")
            }catch {
                print("error")
            
            
        }
        // reshaem problemy otobraženija nowux dobawlenux dannux 4erez ispolzowanije "self.navigationController?.popViewController(animated: true)"
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // wozwras4aemsia na glawnuj ekran pri nažatii na knopky save
        self.navigationController?.popViewController(animated: true)
        
    }
}
