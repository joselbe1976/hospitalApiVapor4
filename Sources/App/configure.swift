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
    app.jwt.signers.use(.hs256(key: "2020AppleCoding2019"))

    // register routes
    try routes(app)
}
