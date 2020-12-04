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
   
    // Relacion N a N con Doctors. Asi accedo desde un paciente a sus doctores
    @Siblings(through: PatientsDoctors.self, from: \.$patient, to: \.$doctor ) var doctors:[Doctors]
    
    
    init(){}
    
    init(id:UUID? = nil, name:String, nif:String){
        self.id = id
        self.name = name
        self.nif = nif
    }
}
