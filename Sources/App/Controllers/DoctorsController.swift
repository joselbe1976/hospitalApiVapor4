//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 5/12/20.
//

import Fluent
import Vapor
import JWT

struct DoctorsController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        // Seguridad JWT
        let tokenAppjwt = routes.grouped("api","doctors")
        
        /*
        tokenAppjwt.get("allday", use: testTokenJWTDoctor)
        tokenAppjwt.post("save", use: testTokenJWTPatient)
        tokenAppjwt.put("update", use: testTokenJWTPatient)
        tokenAppjwt.get("showlistpatients", use: testTokenJWTPatient)
        */
    }
}
