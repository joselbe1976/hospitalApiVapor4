import Vapor
import Fluent

struct Specialities_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Specialities.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Specialities.schema)
            .delete()
    }
}


struct Doctors_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Doctors.schema)
            .id()
            .field("name", .string, .required)
            .field("speciality", .uuid, .required)
            .foreignKey("speciality", references: Specialities.schema, "id", onDelete: .restrict, onUpdate: .cascade, name: "FK_Doctors_Speciality") // FK con Tabla Specialidades
           
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Doctors.schema)
            .delete()
    }
}

struct Patients_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Patients.schema)
            .id()
            .field("name", .string, .required)
            .field("nif", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Patients.schema)
            .delete()
    }
}

// Tabla N a N (medicos y pacientes)
struct PatientsDoctors_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PatientsDoctors.schema)
            .id()
            .field("patient", .uuid, .required, .references(Patients.schema, "id"))
            .field("doctor", .uuid, .required, .references(Doctors.schema, "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PatientsDoctors.schema)
            .delete()
    }
}


struct MedicalAppointments_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MedicalAppointments.schema)
            .id()
            .field("date", .date, .required)
            .field("hour", .int, .required)
            .field("treatment", .string)  //optional
            .field("reserved", .int, .required) // default value 0 in models
            .field("doctor", .uuid, .required) // El doctor siempre es requerido
            .foreignKey("doctor", references: Doctors.schema, "id", onDelete: .cascade, onUpdate: .cascade, name: "FK_Doctor_Appointment") // FK con Tabla Doctors.
            .field("patient", .uuid) // not required. Is optional
            .foreignKey("patient", references: Patients.schema, "id", onDelete: .setNull, onUpdate: .cascade, name: "FK_Patient_Appointment")  // FK con Tabla Categories
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MedicalAppointments.schema)
            .delete()
    }
}



struct CreateUsersApp_v1 : Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UsersApp.schema)
            .id()
            .field(.email, .string, .required)
            .field(.password, .string, .required)
            .unique(on: .email) // email dato único
            .field("doctor", .uuid) // opcional
            .foreignKey("doctor", references: Doctors.schema, "id", onDelete: .cascade, onUpdate: .cascade, name: "FK_Doctor_UsersApp") // FK con Tabla Doctors.
            .field("patient", .uuid) // opcional
            .foreignKey("patient", references: Patients.schema, "id", onDelete: .setNull, onUpdate: .cascade, name: "FK_Patient_UsersApp")  // FK con Tabla
            .create()
    }
    
    // si se hecha a tras la migración
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UsersApp.schema)
            .delete()
    }
}


/*
struct CreateUserToken_V1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema)
            .id()
            .field("user_id", .uuid, .references(UsersApp.schema, "id"))
            .field("tokenValue", .string, .required).unique(on: "tokenValue")
            .field("create", .datetime, .required)
            .field("expiration", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema)
            .delete()
    }

}
*/


struct Create_Data_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
      let data1 = Specialities(name: "Pediatría")
      let data2 = Specialities(name: "Oftalmología")
      let data3 = Specialities(name: "Cardiología")
      let data4 = Specialities(name: "Medicina General")
      
        // ejecutar un array de EventLoopFuture<void> (un bucle de ejecucion)
      return .andAllSucceed([
            data1.create(on: database),
            data2.create(on: database),
            data3.create(on: database),
            data4.create(on: database)
        ], on: database.eventLoop)
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        Specialities.query(on: database).delete()  // eliminamos los datos
    }
    
    

    
}

