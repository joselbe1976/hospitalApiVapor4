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
    let keyS = SymmetricKey(data: Data(OfuscateData))
    
    func boot(routes: RoutesBuilder) throws {
        
        // Seguridad JWT
        let tokenAppjwt = routes.grouped("api","patients")
       
        tokenAppjwt.get("specialities", use: getAllScpecialities) // devuelve las especialidades
        tokenAppjwt.post("doctors", use: doctorsBySpeciality) // busca doctores por especialidad
        tokenAppjwt.post("agenda", use: doctorAgenda)  // Adenda del doctor para un día. Muestra horas libres
        tokenAppjwt.put("register", use: patientRegisterAgenda) // registro del paciente en la agenda dle medico libre
        tokenAppjwt.get("citas", use: getCitasPaciente)
    }

    //Devuelve todas las citas de un Paciente
    func getCitasPaciente(_ req:Request) throws -> EventLoopFuture<[MedicalAppointments]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
        
        return MedicalAppointments
            .query(on: req.db)
            .filter(\.$patient.$id == payload.identify)
            .with(\.$patient)
            .with(\.$doctor){ doctor in
                doctor.with(\.$speciality)
            }
            .all()
    }
    
    
    // Paciente se apunta a la agenda de un medico para un día y hora
    func patientRegisterAgenda(_ req:Request) throws -> EventLoopFuture<HTTPStatus> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        // Decode JSOn Body
        let filters = try req.content.decode(MedicalAppointmentsRequestFilter.self)
        
        guard let ifFilter = filters.id else{
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        //Verificamos que ese ID no hay otro paciente ya registrado previamente a esta solicitud
     
        return MedicalAppointments
            .find(ifFilter, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ apppointment in
                // si no hay asignado un paciente,se puede reservar
                if let _ = apppointment.$patient.id {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest)) // ya hay un paciente, le indicamos error de solicitud
                }else{
                    // No asignado, se puede registrar el paciente conectado de la solicitud
                    apppointment.$patient.id = payload.identify // asigno el identificador del paciente del payload
                    apppointment.reserved = 1 // se marca como reservado
                    return apppointment
                        .update(on: req.db)
                        .flatMap {
                            // llamadamos a la funcion para grabar en Tabla N a N en medicos-pacientes
                            return  patientRegisterAgenda(req: req, idDoctor: apppointment.$doctor.id, idPatient: payload.identify)
                        }
                }
               
                
            }
    }
    
    // se encarga de añadir a la tabla N a N medicos-pacientes
    func patientRegisterAgenda(req:Request, idDoctor:UUID , idPatient:UUID)  -> EventLoopFuture<HTTPStatus>{
       
        let  doctorQuery = Doctors
                            .find(idDoctor, on: req.db)
                            .unwrap(or: Abort(.notFound))
           
        let patientQuery = Patients
                            .find(idPatient, on: req.db)
                            .unwrap(or: Abort(.notFound))
        
        return doctorQuery.and(patientQuery)
            .flatMap{ doctor, patient in
                
                guard let docID = doctor.id,
                      let patientID = patient.id else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                }
                
                return PatientsDoctors.query(on: req.db)
                   .group(.and){ group in
                       group
                        .filter(\.$doctor.$id == docID)
                        .filter(\.$patient.$id == patientID)
                   }
                   .first()
                   .flatMap{ exist in
                       if exist == nil {
                           return doctor
                               .$patients
                               .attach(patient, on: req.db)
                               .transform(to: .created)
                       } else {
                        // ya existe la relacion paciente-doctor, asi que todo OK
                        return req.eventLoop.makeFailedFuture(Abort(.created))
                       }
                   }
            }
        
    }
    
    
    
    // devuelve la aegnda de un doctor en una fecha.
    func doctorAgenda(_ req:Request) throws -> EventLoopFuture<[MedicalAppointments]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        // Decode JSOn Body
        let filters = try req.content.decode(MedicalAppointmentsRequestFilter.self)
        
        guard let dateFilter = filters.date, let doctorIdFiltrer = filters.doctorID else{
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return MedicalAppointments
            .query(on: req.db)
            .group(.and){ group in
                group
                    .filter(\.$doctor.$id  == doctorIdFiltrer)
                    .filter(\.$date == dateFilter)
                    .filter(\.$reserved == 0)
            }
            .with(\.$patient)
            .with(\.$doctor)
            .all()
     
    }
    
    // Lista de médicos por especialidad
    func doctorsBySpeciality(_ req:Request) throws -> EventLoopFuture<[Doctors]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        // Decode JSOn Body
        let filters = try req.content.decode(DoctorBySpecialityFilter.self)

        guard let specialityIdFilter = filters.speciality else{
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        return Doctors
            .query(on: req.db)
            .filter(\.$speciality.$id == specialityIdFilter)
            .all()
    }
    
    // Lista de especialidades
    func getAllScpecialities(_ req:Request) throws -> EventLoopFuture<[Specialities]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
     
        return Specialities
            .query(on: req.db)
            .all()
    }
}
