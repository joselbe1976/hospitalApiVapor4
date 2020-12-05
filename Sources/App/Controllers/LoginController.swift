//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 5/12/20.
//

import Fluent
import Vapor
import JWT

struct LoginController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        // Seguridad AppUser. (usuario y clave)
        let app = routes.grouped("api","auth")
            .grouped(UsersApp.authenticator())
            .grouped(UsersApp.guardMiddleware())
        app.post("login", use: loginJWT)
        
        
        // Seguridad JWT
        let tokenAppjwt = routes.grouped("api","jwt")
        tokenAppjwt.get("testdoctor", use: testTokenJWTDoctor)
        tokenAppjwt.get("testpatient", use: testTokenJWTPatient)
    
    }
    
    func loginJWT(_ req:Request) throws -> String{
        print("entra Login")
     
        let user = try req.auth.require(UsersApp.self)
   
        //Creo el Payload
        var isADoctor : Bool = false
        var identify : UUID? = nil
        
        if let doctor = user.$doctor.id {
            isADoctor = true
            identify = doctor
        } else if let patient = user.$patient.id{
            isADoctor = false
            identify = patient
        }
        
        let payload = PayloadApp(email: .init(value: user.email), expiration: .init(value: .distantFuture), isDoctor: isADoctor, identify: identify!)
  
        // Firmamos con RSA256
        let token  = try req.jwt.sign(payload, kid: JWKIdentifier(string: "private"))
       
        return token
    }
    
    
    // ejecutamos para probar la seguridad
    func testTokenJWTDoctor(_ req:Request) throws -> EventLoopFuture<String> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        
        if !payload.isDoctor{
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        return req.eventLoop.makeSucceededFuture("Todo Correcto Doctor: \(payload.email.value)")
        
    }
    
    func testTokenJWTPatient(_ req:Request) throws -> EventLoopFuture<String> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        
        if payload.isDoctor{
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        return req.eventLoop.makeSucceededFuture("Todo Correcto Paciente: \(payload.email.value)")
        
    }
}
