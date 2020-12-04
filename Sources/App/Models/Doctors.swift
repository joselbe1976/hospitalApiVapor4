//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 4/12/20.
//


import Vapor
import Fluent

// Doctores
final class Doctors : Model , Content{
    static let schema = "doctors"
    
    @ID(custom: "id") var id:UUID?
    @Field(key: "name") var name:String
    @Parent(key: "speciality")  var speciality:Specialities // 1-1 relation NO optional

    init(){}
    
    init(id:UUID? = nil, name:String, speciality:UUID){
        self.id = id
        self.name = name
        self.$speciality.id = speciality
    }
}

