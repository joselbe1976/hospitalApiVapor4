import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor
import JWT


// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Create Migration tables
    app.migrations.add(Specialities_v1())
    app.migrations.add(Doctors_v1())
    app.migrations.add(Patients_v1())
    app.migrations.add(PatientsDoctors_v1())
    app.migrations.add(MedicalAppointments_v1())
    app.migrations.add(CreateUsersApp_v1())
   // app.migrations.add(CreateUserToken_V1())

    // Data init
    app.migrations.add(Create_Data_v1())

    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease // activa la cache solo en produccion, y no en Desarrollo

    
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



let datoOfuscado:[UInt8] = [0x34+0x1C,0x59+0x0C,0xA1-0x3D,0x91-0x30,0x13+0x67,0x14+0x5B,0x07+0x3D,0x97-0x32,0x84-0x41,0xB9-0x4D,0x88-0x27,0x87-0x11,0x71-0x0C,0x49-0x05,0x7D-0x18,0x72-0x26,0x7B-0x1A,0x73-0x23,0x78-0x06,0xBD-0x5C,0x61+0x03,0x07+0x5E,0xA2-0x30,0x32+0x2F,0x64-0x2D,0x3F+0x04,0x8D-0x2C,0x28+0x3A,0x4B+0x16,0x16+0x56,0x93-0x27,0x4B+0x24]

extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}

