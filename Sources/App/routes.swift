import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: LoginController())  // login JWT
    try app.register(collection: RegisterController())  //registro de Doctores y pacientes
    try app.register(collection: PatientsController())  //funcional pacientes
    try app.register(collection: DoctorsController())  //funcional doctores
    
    // For Web Leaf security
    let sessions = app.grouped(app.sessions.middleware) // necesario para que las llamadas vayan por el midleware
    try sessions.register(collection: WebLoginController()) // Login Web
    try sessions.register(collection: WebDoctorController()) // Lista doctores
    
}
