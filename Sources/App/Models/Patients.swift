//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 4/12/20.
//

import Vapor
import Fluent

// Pacientes
final class Patients : Model , Content{
    static let schema = "patients"
    
    @ID(custom: "id") var id:UUID?
    @Field(key: "name") var name:String
    @Field(key: "nif") var nif:String
    // other possibles: fecha nacimiento
   
    init(){}
    
    init(id:UUID? = nil, name:String, nif:String){
        self.id = id
        self.name = name
        self.nif = nif
    }
}
