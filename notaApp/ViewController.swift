//
//  ViewController.swift
//  notaApp
//
//  Created by Jonh Parra on 04/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    

    @IBOutlet weak var tabla: UITableView!
    var categorias = [Categorias]()
    var fetchResultController: NSFetchedResultsController<Categorias>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabla.delegate = self
        tabla.dataSource = self
        mostrarCategorias()
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabla.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let categoria = categorias[indexPath.row]
        cell.textLabel?.text = categoria.nombre
        return cell
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "notas", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notas" {
            if let id = tabla.indexPathForSelectedRow {
                let fila = categorias[id.row]
                let destino = segue.destination as! NotasTableViewController
                destino.categoria = fila
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let eliminar = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
//            let contexto = Conexion().context()
//            let borrar = self.fetchResultController.object(at: indexPath)
//            contexto.delete(borrar)
//
//            do{
//                try contexto.save()
//            }catch let error as NSError {
//                print("Ocurrio un erro al eliminar la nota", error.localizedDescription)
//            }
//        }
//
//        return [eliminar]
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let eliminar = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let contexto = Conexion().context()
            let borrar = self.fetchResultController.object(at: indexPath)
            contexto.delete(borrar)

            do{
                try contexto.save()
            }catch let error as NSError {
                print("Ocurrio un erro al eliminar la nota", error.localizedDescription)
            }
        }

        return [eliminar]

    }

    
    
    //MARK: GUARDAR EN ALERTA
    
    @IBAction func guardar(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nueva Categoria", message: "Ingresa nombre de categoria", preferredStyle: .alert)
        alert.addTextField{ (nombre) in
            nombre.placeholder = "Nombre de categoria"
        }
        
        let aceptar = UIAlertAction(title: "Aceptar", style: .default) { (action) in
            guard let nombre = alert.textFields?.first?.text else { return }
            let contexto = Conexion().context()
            
            let entityCategorias = NSEntityDescription.insertNewObject(forEntityName: "Categorias", into: contexto)  as! Categorias
            entityCategorias.id = UUID()
            entityCategorias.nombre = nombre
            
            do{
                try contexto.save()
                print("Guardado con éxito")
            } catch let error as NSError {
                print("Ocurio un error al guardar \(error.localizedDescription)")
            }
            
        }
        
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        
        alert.addAction(aceptar)
        alert.addAction(cancelar)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    //MARK: FETCH RESULT CONTROLLER
    func mostrarCategorias () {
        let contexto = Conexion().context()
        let fetchRequest: NSFetchRequest<Categorias> = Categorias.fetchRequest()
//         SELECT nombre FROM categorias ORDER BY nombre ASC o DESC
        let orderByNombre = NSSortDescriptor(key: "nombre", ascending: true)
        fetchRequest.sortDescriptors = [orderByNombre]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            categorias = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("Ocurrio un problema \(error.localizedDescription)")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tabla.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tabla.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tabla.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tabla.reloadData()
        }
        
        self.categorias = controller.fetchedObjects as! [Categorias]
    }
    

    //MARK: COMPROBAR RELACIONES EN CONSOLA
    
    @IBAction func comprobar(_ sender: UIBarButtonItem) {
        let contexto = Conexion().context()
        let fetchRequest : NSFetchRequest<Categorias> = Categorias.fetchRequest()
        do {
            let resultados = try contexto.fetch(fetchRequest)
            print("Numero de categorias", resultados.count)
            for res in resultados as [NSManagedObject]{
                let nombre = res.value(forKey: "nombre")
                print("Nombre: \(nombre!)")
            }
        } catch let error as NSError {
            print("Ocurrio un problema" , error.localizedDescription)
        }
        
        let fetchRequest2 : NSFetchRequest<Notas> = Notas.fetchRequest()
        do {
            let resultados2 = try contexto.fetch(fetchRequest2)
            print("Numero de notas", resultados2.count)
            for res2 in resultados2 as [NSManagedObject]{
                let titulo = res2.value(forKey: "titulo")
                print("Titulo> \(titulo!)")
            }
        } catch let error as NSError {
            print("Ocurrio un problema" , error.localizedDescription)
        }
        
        let fetchRequest3: NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        do {
                 let resultados3 = try contexto.fetch(fetchRequest3)
                 print("Numero de fotos", resultados3.count)
             } catch let error as NSError {
                 print("Ocurrio un problema" , error.localizedDescription)
             }

    }
    
    
}

