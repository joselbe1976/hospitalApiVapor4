import Fluent
import Vapor

struct RegisterController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("api","register")
        app.post("doctors", use: doctorRegister)
        app.post("patients", use: patientRegister)
    }
    
    // // Register a Doctor in the System
    func doctorRegister(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        var registerDoctor = try req.content.decode(DoctorRegister.self)
        registerDoctor.password = try req.password.hash(registerDoctor.password)
        let doc = Doctors(name: registerDoctor.name, speciality: registerDoctor.especialidad)
        
        // verificamos si existe el mail como usuario, entonces error
       return Doctors
            .query(on: req.db)
            .filter(\.$name == registerDoctor.name)  // en REAL sería por NIF o algo asi.
            .first()
            .flatMap{ exist in
                if exist == nil{
                    return doc
                        .create(on: req.db)
                        .flatMap{
                            // creamos el usuario de la Aplicación
                            let user = UsersApp(email: registerDoctor.email , password: registerDoctor.password, patient: nil, doctor : doc.id)
                            return user
                                .create(on: req.db)
                                .transform(to: .ok)
                        }
                }else{
                    // si existe, damos error
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                }
            }
    }
    
    // Register a Patient in the System
    func patientRegister(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        var registerPatient = try req.content.decode(PatientsRegister.self)
        registerPatient.password = try req.password.hash(registerPatient.password)
        
        let pat = Patients(name: registerPatient.name, nif: registerPatient.nif)
 
        // verificamos si existe el Paciente por NIF
       return Patients
            .query(on: req.db)
            .filter(\.$nif == registerPatient.nif)
            .first()
            .flatMap{ exist in
                if exist == nil{
                    return pat
                        .create(on: req.db)
                        .flatMap{
                            // creamos el usuario de la Aplicación
                            let user = UsersApp(email: registerPatient.email , password: registerPatient.password, patient: pat.id, doctor : nil)
                            return user
                                .create(on: req.db)
                                .transform(to: .ok)
                        }
                }else{
                    // si existe, damos error
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                }
            }
    }
}



