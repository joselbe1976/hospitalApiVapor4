import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: LoginController())  // login JWT
    try app.register(collection: RegisterController())  //registro de Doctores
    try app.register(collection: PatientsController())  //funcional doctores
    try app.register(collection: DoctorsController())  //funcional pacientes
    
}
