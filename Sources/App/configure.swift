import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import JWT


// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // SQL LITE
    //app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    //POStGRE
    if let environment = Environment.get("DATABASE_URL"), let databaseURL = URL(string: environment) {
        // Conexion en Heroku
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        // Conexion a mi servidor.
        
       fatalError("DATABASE_URL is not configurated in Heroku")
       
    }
    
    
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease // activa la cache solo en produccion, y no en Desarrollo

    // midlewares de Seguridad para la Web Leaf
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(UsersApp.sessionAuthenticator())
    

    // Create Migration tables
    app.migrations.add(Specialities_v1())
    app.migrations.add(Doctors_v1())
    app.migrations.add(Patients_v1())
    app.migrations.add(PatientsDoctors_v1())
    app.migrations.add(MedicalAppointments_v1())
    app.migrations.add(CreateUsersApp_v1())


    // Data init
    app.migrations.add(Create_Data_v1())


    
    
    //encriptacion del sistema
    app.passwords.use(.bcrypt)
    
    //JWT Config
   // app.jwt.signers.use(.hs256(key: "2020AppleCoding2019"))
    
    //COnfig JWT con Key certificados RSA256 -------
    // securizamos con clave provada
    
    let url = URL(fileURLWithPath: app.directory.workingDirectory).appendingPathComponent("jwtRS256.key.prv")
    let urlPub = URL(fileURLWithPath: app.directory.workingDirectory).appendingPathComponent("jwtRS256.key.pub")
    
    let privateKey = try Data(contentsOf: url)
    let publicKey = try Data(contentsOf: urlPub)
    
    let signerPublic = try JWTSigner.rs256(key: .public(pem: publicKey))
    let signerPrivate = try JWTSigner.rs256(key: .private(pem: privateKey))
    
    app.jwt.signers.use(signerPublic, kid: .public, isDefault: true)
    app.jwt.signers.use(signerPrivate, kid: .private) 
    
    
    // register routes
    try routes(app)
}


let OfuscateData:[UInt8] = [0x7F-0x2A,0xC2-0x54,0x19+0x2A,0x2B+0x36,0x40+0x22,0x09+0x58,0xD6-0x6A,0x96-0x2A,0xC7-0x58,0x6D-0x2B,0x2F+0x3D,0x0B+0x56,0x9B-0x2D,0x98-0x35,0x21+0x4E,0x3C+0x1A,0x35+0x34,0x67-0x02,0x8D-0x1F,0x4F+0x16,0x64-0x00,0x56+0x0F,0x1D+0x25,0x35+0x3A,0x53+0x1B,0xC1-0x60,0x8B-0x1D,0x5B+0x1F,0x56+0x0B,0x0E+0x53,0x73-0x12,0x87-0x26]


extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}

