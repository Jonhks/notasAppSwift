//
//  AgregarNotaViewController.swift
//  notaApp
//
//  Created by Jonh Parra on 05/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import UIKit
import CoreData


class AgregarNotaViewController: UIViewController {
    
    @IBOutlet weak var tituloText: UITextField!
    var categoria: Categorias!
    var notas: Notas!
    @IBOutlet weak var notaText: UITextView!
    var editarGuardar: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  editarGuardar {
            let buttonSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(agregarNota))
              navigationItem.rightBarButtonItem =  buttonSave
        } else {
            let buttonEdit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editarNota))
              navigationItem.rightBarButtonItem =  buttonEdit
            tituloText.text = notas.titulo
            notaText.text = notas.texto

        }
        

        // Do any additional setup after loading the view.
    }
    
    
    @objc func agregarNota () {
        let contexto = Conexion().context()
        let entityNotas = NSEntityDescription.insertNewObject(forEntityName: "Notas", into: contexto) as! Notas
        entityNotas.id = UUID()
        entityNotas.id_categoria = categoria.id
        entityNotas.titulo = tituloText.text
        entityNotas.texto = notaText.text
        entityNotas.fecha = Date()
        
        categoria.mutableSetValue(forKey: "relationToNotas").add(entityNotas)
        
        do {
            try contexto.save()
            print("Nota guardada")
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Hubo un error al guardar la nota \(error.localizedDescription)")
        }
    }
    
    
    @objc func editarNota () {
          let contexto = Conexion().context()
        notas.setValue(tituloText.text, forKey: "titulo")
        notas.setValue(notaText.text, forKey: "texto")
        notas.setValue(Date(), forKey: "fecha")

          do {
              try contexto.save()
              print("Nota editada")
              navigationController?.popViewController(animated: true)
          } catch let error as NSError {
              print("Hubo un error al editar la nota \(error.localizedDescription)")
          }
      }

}
