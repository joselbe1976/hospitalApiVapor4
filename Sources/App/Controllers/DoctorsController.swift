//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 5/12/20.
//

import Fluent
import Vapor
import JWT

struct DoctorsController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        // Seguridad JWT
        let tokenAppjwt = routes.grouped("api","doctors")
       
        tokenAppjwt.post("add", use: addAgendDay) //Añade a la agenda para una fecha y hora
        tokenAppjwt.get("all", use: getAllDays) // devuelve todo lo de un medico de la agenda
        tokenAppjwt.put("treatment", use: addTreatment) // asigna tratamiento para un dia y hora, siempre que haya paciente
        tokenAppjwt.post("patientsdaylist", use: patientsDayList) // devuelve la agenda de un día con pacientes asignados
    

    }
    
    // Lista de pacientes para un día del médico conectado
    func patientsDayList(_ req:Request) throws -> EventLoopFuture<[MedicalAppointments]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if !payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
        
        // Decode JSOn Body
        let filters = try req.content.decode(MedicalAppointmentsRequestFilter.self)
     
        return  MedicalAppointments
            .query(on: req.db)
            .group(.and){ group in
                group
                    .filter(\.$doctor.$id == payload.identify)
                    .filter(\.$date == filters.date!)
                    .filter(\.$reserved == 1)
            }
            .with(\.$patient)
            .with(\.$doctor)
            .all()
           /* .map{ data in
                
                data.map{ dataDay in
                    MedicalAppointmentsResponse(id: dataDay.id!, date: dataDay.date, hour: dataDay.hour, treatment: dataDay.treatment, doctorID: dataDay.doctor.id!, patientID: dataDay.patient?.id ?? nil, reserved: dataDay.reserved, patientName: dataDay.$patient.value.na)
                }
            }
 */
    }
    
    // actualiza el trataniento de una cita
    func addTreatment(_ req:Request) throws -> EventLoopFuture<HTTPStatus> {
        //JWT
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if !payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
        
        // Decode JSOn Body
        let requestMedicaApointment = try req.content.decode(MedicalAppointmentsRequestTreatment.self)
        
        // busco el dato y actualizo
        return MedicalAppointments
            .find(requestMedicaApointment.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ apppointment in
                // si no hay asignado un paciente, no se puede actualizar el tratamiento
                if let _ = apppointment.$patient.id {
                    apppointment.treatment = requestMedicaApointment.treatment
                    return apppointment
                        .update(on: req.db)
                        .transform(to: .ok)
                    
                }else{
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                }
               
                
            }
        
       
    }
    
    //añade un día a la egenda
    func addAgendDay(_ req:Request) throws -> EventLoopFuture<HTTPStatus> {
        //JWT
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if !payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
        
        // Decode JSOn Body
        let requestMedicaApointment = try req.content.decode(MedicalAppointmentsRequest.self)
        
        // create the model
        let dataSave = MedicalAppointments(date: requestMedicaApointment.date, hour: requestMedicaApointment.hour, treatment: requestMedicaApointment.treatment, doctor: requestMedicaApointment.doctorID, patient: nil)
        // Grabo (sin validaciones aún)
        return dataSave
            .save(on: req.db)
            .transform(to: .ok)
    }

    //devuelve todos los días de agenda de un doctor conectado por el token
    func getAllDays(_ req:Request) throws -> EventLoopFuture<[MedicalAppointmentsResponse]> {
        let payload = try req.jwt.verify(as: PayloadApp.self)
        if !payload.isDoctor{ return req.eventLoop.makeFailedFuture(Abort(.badRequest))}
        
        return  MedicalAppointments
            .query(on: req.db)
            .with(\.$patient)
            .with(\.$doctor)
            .filter(\.$doctor.$id == payload.identify)
            .all()
            .map{ data in
                
                data.map{ dataDay in
                    MedicalAppointmentsResponse(id: dataDay.id!, date: dataDay.date, hour: dataDay.hour, treatment: dataDay.treatment, doctorID: dataDay.doctor.id!, patientID: dataDay.patient?.id ?? nil, reserved: dataDay.reserved)
                }
            }
    }
}
