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
       /*
        tokenAppjwt.get("specialities", use: testTokenJWTDoctor)
        tokenAppjwt.get("doctors", use: testTokenJWTPatient)
        tokenAppjwt.get("agendadiadoctor", use: testTokenJWTPatient)
        tokenAppjwt.put("register", use: testTokenJWTPatient)
        tokenAppjwt.get("citas", use: testTokenJWTPatient)
 */
    
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
