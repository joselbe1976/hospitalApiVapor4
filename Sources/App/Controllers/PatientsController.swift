//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 5/12/20.
//

import Fluent
import Vapor
import JWT

struct PatientsController : RouteCollection {
    let keyS = SymmetricKey(data: Data(datoOfuscado))
    
    func boot(routes: RoutesBuilder) throws {
        
        // Seguridad JWT
        let tokenAppjwt = routes.grouped("api","patients")
       
        tokenAppjwt.get("specialities", use: getAllScpecialities) // devuelve las especialidades
        tokenAppjwt.post("doctors", use: doctorsBySpeciality) // busca doctores por especialidad
        tokenAppjwt.post("agenda", use: doctorAgenda)  // Adenda del doctor para un día. Muestra horas libres
        /*
        
  
        tokenAppjwt.put("register", use: testTokenJWTPatient)
        tokenAppjwt.get("citas", use: testTokenJWTPatient)
 */
    
    }
    
    
    func doctorAgenda(_ req:Request) throws -> EventLoopFuture<[MedicalAppointments]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        // Decode JSOn Body
        let filters = try req.content.decode(MedicalAppointmentsRequestFilter.self)
        
        return MedicalAppointments
            .query(on: req.db)
            .group(.and){ group in
                group
                    .filter(\.$doctor.$id  == filters.doctorID!)
                    .filter(\.$date == filters.date!)
                    .filter(\.$reserved == 0)
            }
            .with(\.$patient)
            .with(\.$doctor)
            .all()
     
    }
    
    
    func doctorsBySpeciality(_ req:Request) throws -> EventLoopFuture<[Doctors]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        // Decode JSOn Body
        let filters = try req.content.decode(DoctorBySpecialityFilter.self)
        
        return Doctors
            .query(on: req.db)
            .filter(\.$speciality.$id == filters.speciality!)
            .all()
            
        
    }
    
    func getAllScpecialities(_ req:Request) throws -> EventLoopFuture<[Specialities]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        return Specialities
            .query(on: req.db)
            .all()
    }
    
}


/*
 ofuscar el JSON
 */
/*
func getAll(_ req:Request) throws -> EventLoopFuture<CipherResponse> {
    try req.auth.require(UserToken.self)
    return Scores
        .query(on: req.db)
        .with(\.$composer) { composer in
            composer.with(\.$nationality)
        }
        .with(\.$category)
        .all()
        .flatMapThrowing { composers in
            guard let composerJSON = try? JSONEncoder().encode(composers),
                  let mensajeCifrado = try? AES.GCM.seal(composerJSON, using: keyS),
                  let cifrado = mensajeCifrado.combined?.base64EncodedString() else {
                throw Abort(.notFound)
            }
            return CipherResponse(node: cifrado)
        }
}
 */
