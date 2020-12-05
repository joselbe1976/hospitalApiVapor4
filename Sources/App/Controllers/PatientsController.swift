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
    func boot(routes: RoutesBuilder) throws {
        
        // Seguridad JWT
        let tokenAppjwt = routes.grouped("api","patients")
       /*
        tokenAppjwt.get("specialities", use: testTokenJWTDoctor)
        tokenAppjwt.get("doctors", use: testTokenJWTPatient)
        tokenAppjwt.get("agendadiadoctor", use: testTokenJWTPatient)
        tokenAppjwt.put("register", use: testTokenJWTPatient)
        tokenAppjwt.get("citas", use: testTokenJWTPatient)
 */
    
    }
}

