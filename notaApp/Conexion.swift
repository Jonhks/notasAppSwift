//
//  Conexion.swift
//  notaApp
//
//  Created by Jonh Parra on 04/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Conexion {
    func context () -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
}
