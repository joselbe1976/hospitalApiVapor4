//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 4/12/20.
//

import Vapor
import Fluent

// Citas Medicas
final class MedicalAppointments : Model , Content{
    static let schema = "medical_appointments"
    
    @ID(custom: "id") var id:UUID?  // IDentificador de la cita
    @Field(key: "date") var date : Date // Día disponibilidad
    @Field(key: "hour") var hour : Int // hora disponible
    @Field(key: "treatment") var treatment : String? // opcional. Solo se rellena cuando el medico rellena el tratamiento
    @Parent(key: "doctor") var doctor:Doctors  // medico de la cita
    @OptionalParent(key: "patient") var patient:Patients? // opcional el Paciente, Se rellena al apuntarse a la cita médica
    @Field(key: "reserved") var reserved : Int // 0 = No reservado / 1 = si. Para filtros. Se pone a 1 cuando un paciente reserva con el doctor.
    
    init(){}
    
    init(id:UUID? = nil, date:Date, hour:Int, treatment:String?, doctor:UUID, patient:UUID?, reserved:Int=0){
        self.id = id
        self.date = date
        self.hour = hour
        self.treatment = treatment
        self.$doctor.id = doctor
        self.$patient.id = patient
        self.reserved = reserved
        
        
    }
}

// Response encript
struct CipherResponse:Content {
    let node:String
}

struct MedicalAppointmentsRequest : Content {
    var id:UUID?
    var date : Date
    var hour : Int
    var treatment : String?
    var doctorID : UUID
    var patientID : UUID?
    var reserved: Int?
}

struct  MedicalAppointmentsResponse : Content {
    var id:UUID
    var date : Date
    var hour : Int
    var treatment : String?
    var doctorID : UUID
    var patientID : UUID?
    var reserved: Int?
    var patientName : String?
}

struct  MedicalAppointmentsRequestTreatment : Content {
    var id:UUID
    var treatment : String?
}

// Se usa para poder hacer filtros sobre la agenda (Citas medicas)
struct MedicalAppointmentsRequestFilter : Content {
    var id:UUID?
    var date : Date?
    var hour : Int?
    var patientID : UUID?
    var reserved: Int?
    var doctorID : UUID?
}
