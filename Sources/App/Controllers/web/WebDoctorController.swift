//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 10/12/20.
//


import Fluent
import Vapor
import JWT

// Solo para la Web
struct WebDoctorController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Ruta Protegida con el midleware. Sino tiene seguridad al login
        let protected = routes.grouped("web").grouped(UsersApp.redirectMiddleware(path: "/web/login"))
        protected.get("doctors", use: doctorsListView)
    }
    
    // Lista de Doctores que hay en la base de datos
    func doctorsListView(_ req:Request) throws -> EventLoopFuture<View>{
         Doctors
            .query(on: req.db)
            .with(\.$speciality)
            .all()
            .flatMap { doctors  in
                let doctorsData = doctors.map{
                    DoctorsDataView(name: $0.name, speciality: $0.speciality.name)
                }
                
                let context = DoctorsView(name: "Jose Luis Bustos", doctors: doctorsData)
                return req.view.render("doctors", context)
            }
    }
    
}

struct DoctorsDataView : Encodable {
    let name :String //nombre doctor.
    let speciality:String //name espciality
}

struct DoctorsView:Encodable {
    let name:String
    let doctors:[DoctorsDataView]
}

