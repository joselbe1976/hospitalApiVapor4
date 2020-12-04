//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 4/12/20.
//


import Vapor
import Fluent

// Especialidades Médica
final class Specialities : Model , Content{
    static let schema = "Specialities"
    
    @ID(custom: "id") var id:UUID?
    @Field(key: "name") var name:String
   
    init(){}
    
    init(id:UUID? = nil, name:String){
        self.id = id
        self.name = name
    }
}
