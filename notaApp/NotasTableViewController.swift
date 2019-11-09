//
//  NotasTableViewController.swift
//  notaApp
//
//  Created by Jonh Parra on 05/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import UIKit
import CoreData

class NotasTableViewController: UITableViewController, NSFetchedResultsControllerDelegate  {
    
    var notas = [Notas]()
    var fetchResultController: NSFetchedResultsController<Notas>!
    var categoria: Categorias!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categoria.nombre
        
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(agregarNota))
        navigationItem.rightBarButtonItem =  buttonAdd
        
        mostrarNotas()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    //MARK: FUNCION DE AGREGAR NOTAS
    
    
    @objc func agregarNota () {
        performSegue(withIdentifier: "agregarNota", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "agregarNota" {
            let destino = segue.destination as! AgregarNotaViewController
            destino.categoria = categoria
            destino.editarGuardar = true
//            destino.notas = notas
        }
        if segue.identifier == "editarNota" {
            if let id = tableView.indexPathForSelectedRow {
                let fila = notas[id.row]
                let destino = segue.destination as! AgregarNotaViewController
                destino.notas = fila
                destino.editarGuardar = false
            }
        }
        
        if segue.identifier == "fotos" {
            let id = sender as! NSIndexPath
            let fila = notas[id.row]
            let destino = segue.destination as! ImagenesCollectionViewController
            destino.notas = fila
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notas.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CeldaTableViewCell
        let nota = notas[indexPath.row]
        cell.titulo.text = nota.titulo
        let formatoFecha = DateFormatter()
//        formatoFecha.dateStyle = .medium
        formatoFecha.dateFormat = "MMM dd , yyyy"
        let fecha = formatoFecha.string(from: nota.fecha!)
        cell.fecha.text = fecha
        // Configure the cell...

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editarNota", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
        
        let camara = UITableViewRowAction(style: .normal, title: "Foto 📷") { (_, indecPath) in
            print("Foto")
            self.performSegue(withIdentifier: "fotos", sender: indexPath)
//        UIContextualAction(style: .normal, title: "Foto 📷") { (UIContextualAction, UIView, @escaping (Bool) -> Void) in
//
//        }
        }
        return [eliminar, camara]
    }
    
    //MARK: FUNCION PARA MOSTRAR FETCHRESULTCONTROLLER
    
    func mostrarNotas () {
        let contexto = Conexion().context()
        let fetchRequest: NSFetchRequest<Notas> = Notas.fetchRequest()
//         SELECT nombre FROM categorias WHERE id_categoria = id ORDER BY nombre ASC o DESC
        let orderByNombre = NSSortDescriptor(key: "titulo", ascending: true)
        fetchRequest.sortDescriptors = [orderByNombre]
        let id_cat = categoria.id
        fetchRequest.predicate = NSPredicate(format: "id_categoria == %@", id_cat! as CVarArg)
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            notas = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("Ocurrio un problema \(error.localizedDescription)")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tableView.reloadData()
        }
        
        self.notas = controller.fetchedObjects as! [Notas]
    }
    
    

    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}
