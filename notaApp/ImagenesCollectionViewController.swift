//
//  ImagenesCollectionViewController.swift
//  notaApp
//
//  Created by Jonh Parra on 05/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import UIKit
import CoreData

class ImagenesCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var imagenesNotas = [Imagenes]()
    var notas : Notas!
    var fotografia: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = notas.titulo
        
        let buttonCamera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(agregarFoto))
              navigationItem.rightBarButtonItem =  buttonCamera
        
        let imageSize = UIScreen.main.bounds.width/4
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: imageSize, height: imageSize)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        collectionView.collectionViewLayout = layout
        mostrarImagenes()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mostrarImagenes()
        collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imagenesNotas.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FotoCollectionViewCell
        let imagenNota = imagenesNotas[indexPath.row]
        if let imagen = imagenNota.imagen {
            cell.foto.image = UIImage(data: imagen as Data)
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "verFoto", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verFoto"{
            let id = sender as! NSIndexPath
            let fila = imagenesNotas[id.row]
            let destino = segue.destination as! VerFotoViewController
            destino.imagenNota = fila
        }
    }
    
    
    @objc func agregarFoto () {
        let alerta =  UIAlertController(title: "Tomar Foto", message: "Camara/Galeria", preferredStyle: .actionSheet)
        
        let camara = UIAlertAction(title: "Tomar Fotografia", style: .default) { (action) in
            self.tomarFotografia()
        }
        let galeria = UIAlertAction(title: "Entrar a galeria", style: .default) { (action) in
            self.entrarAGaleria()
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alerta.addAction(camara)
        alerta.addAction(galeria)
        alerta.addAction(cancelar)
        present(alerta, animated: true, completion: nil)

    }
    
    func tomarFotografia () {
         let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func entrarAGaleria() {
         let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .currentContext
        present(imagePicker, animated: true, completion: nil)

    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let imagenTomada = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        fotografia = imagenTomada
        
        let contexto = Conexion().context()
        let entittyImagenes = NSEntityDescription.insertNewObject(forEntityName: "Imagenes", into: contexto) as! Imagenes
        
        entittyImagenes.id = UUID()
        entittyImagenes.id_notas = notas.id
        let imagenFinal = fotografia.pngData()
        entittyImagenes.imagen = imagenFinal
        
        notas.mutableSetValue(forKey: "relationToImagenes").add(entittyImagenes)
        
        do {
            try contexto.save()
            print("Imagen guardada con éxito")
            self.mostrarImagenes()
            self.collectionView.reloadData()
        } catch let error as NSError {
            print("Ha ocurrido un error al guardar la imagen \(error.localizedDescription)")
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func mostrarImagenes () {
        let contexto = Conexion().context()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        let id = notas.id
        
        fetchRequest.predicate = NSPredicate(format: "id_notas == %@ ", id! as CVarArg)
        
        do {
            imagenesNotas = try contexto.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error al cargar las imagenes \(error.localizedDescription)")
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
