//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 4/12/20.
//

import Fluent
import Vapor

// Tabla N-N Doctores y Pacientes
final class PatientsDoctors : Model {
    static let schema = "patients_doctors"
    
    @ID() var id:UUID?
    @Parent(key: "patient") var patient:Patients
    @Parent(key: "doctor") var doctor:Doctors
    
    init(){}
    
    init(id: UUID? = nil, patient:Patients, doctor:Doctors) throws{
        self.id = id
        self.$patient.id = try patient.requireID()
        self.$doctor.id = try doctor.requireID()
    }
}
