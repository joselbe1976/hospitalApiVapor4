//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 5/12/20.
//

import Vapor
import Fluent

extension FieldKey {
    static var email: FieldKey { "email" }
    static var password: FieldKey { "password" }
    static var activo: FieldKey { "activo" }
}

final class UsersApp : Model, Content{
    static var schema = "users"

    @ID() var id : UUID? // Identificador
    @Field(key: .email) var email:String
    @Field(key: .password) var password:String
    
    //puede ser paciente o doctor, por eso opcionales esta FK
    @OptionalParent(key: "patient") var patient:Patients?
    @OptionalParent(key: "doctor") var doctor:Doctors?
    
    init(){}
    
    init(id:UUID? = nil, email:String, password:String, patient:UUID?, doctor:UUID? ){
        self.id = id
        self.email = email
        self.password = password
        self.$patient.id = patient
        self.$doctor.id = doctor
        
    }

}

// autenticacion basica. ModelAuthenticatable para Web Leaf
extension  UsersApp : ModelAuthenticatable, ModelCredentialsAuthenticatable{
    // Security: Basic Auythetication
    static var usernameKey = \UsersApp.$email
    static var passwordHashKey = \UsersApp.$password
    
    // verifica
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

// para Web
extension UsersApp: SessionAuthenticatable {
    typealias SessionID = UUID
    var sessionID: UUID {
        self.id!
    }
}


//Validacion basica
extension  UsersApp : Validatable{
    // validaciones sobre los datos. de la clase (no es de seguridad). Se ejecuta cuando se hace el decode (recibo JSOn en el endpoint en el POST). Se valida justo antes del decode.
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: Validator.email, required: true)
        validations.add("password", as: String.self, is: .count(8...) && !.empty, required: true)
        // opodemos usar && y Ors.
    }
}


// web

struct UserSessionAuthenticator: SessionAuthenticator {
    typealias User = UsersApp
    
    func authenticate(sessionID: UUID, for request: Request) -> EventLoopFuture<Void> {
        UsersApp.find(sessionID, on: request.db).map { user in
            if let user = user {
                request.auth.login(user)
            }
        }
    }
}
