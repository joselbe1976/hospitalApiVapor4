//
//  File.swift
//
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 2/12/20.
//

import Vapor
import Fluent
import JWT
/*
// modelo Auth2. User - Token
final class UserToken:  Model, Content{
    static let schema = "user_token"
    
    @ID() var id:UUID?
    @Field(key: "tokenValue") var tokenValue:String
    @Field(key: "expiration") var expiration:Date?
    @Timestamp(key: "create", on: .create) var create:Date? // como DT_LAST_UPDTE de meta4. Es automatico
    
    // Relacion tabla usuarios
    @Parent(key: "user_id") var user:UsersApp
    
    init(){}
    
    init(id:UUID? = nil,tokenValue : String , expiration:Date?, userID:UsersApp.IDValue){ // UsersApp.IDValue referencia al id de la tabla
        self.id = id
        self.tokenValue = tokenValue
        self.expiration = expiration
        self.$user.id = userID
        
        
    }
}


extension UserToken : ModelTokenAuthenticatable{
  
    static var valueKey = \UserToken.$tokenValue  // le decimos donde está el Token
    static var userKey = \UserToken.$user
    
    // propiedad calculada. Devolvemos control para validar si el token es valido en datos, pero no el propio token, por ejemplo fecha expiracion
    var isValid : Bool{
       
        // sin fecha expiracion, el token es valido
        guard let expiry = expiration else {
            return true
        }
        return expiry > Date()  // la fecha de expiracion(con hora) sea mayor que ahora
 }
}
 */

// JWT Payload
struct PayloadApp : JWTPayload {
    var email : SubjectClaim  // identifica el sujeto principal del JWT
    var expiration : ExpirationClaim // Expiracion time
    
    var isDoctor : Bool // indicamos si es un doctor
    var identify : UUID // identificador del medico o paciente
    
    // funcion de verificacion: me envian
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired() // verificamos que no haya expirado
    }
}
