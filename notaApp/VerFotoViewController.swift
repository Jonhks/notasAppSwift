//
//  VerFotoViewController.swift
//  notaApp
//
//  Created by Jonh Parra on 08/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import UIKit
import CoreData


class VerFotoViewController: UIViewController {

    @IBOutlet weak var fotografia: UIImageView!
    
    var imagenNota: Imagenes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imagen = imagenNota.imagen {
            fotografia.image = UIImage(data: imagen as Data)
        }
        
        let buttonTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteFoto))
              navigationItem.rightBarButtonItem =  buttonTrash


        // Do any additional setup after loading the view.
    }
    

    @objc func deleteFoto () {
        let contexto = Conexion().context()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        let id = imagenNota.id
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", id! as CVarArg)
        
        do {
            let resultado =  try contexto.fetch(fetchRequest)
            for res in resultado{
                contexto.delete(res)
            }
            try contexto.save()
            print("imagen eliminada con éxito")
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Ocurrio un erro al eliminar la imagen", error.localizedDescription)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
