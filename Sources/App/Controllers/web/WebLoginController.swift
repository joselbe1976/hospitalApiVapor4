//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 10/12/20.
//


import Fluent
import Vapor
import JWT

// Solo para la Web
struct WebLoginController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let webApp = routes.grouped("web")
        webApp.get("login", use: loginInit)
        
        // Login securizado POST
        let credentials = routes.grouped("web").grouped(UsersApp.credentialsAuthenticator())
        credentials.post("login", use: loginWeb)
        
        
        // Ruta Protegida con el midleware. Sino tiene seguridad al login
        let protected = routes.grouped("web").grouped(UsersApp.redirectMiddleware(path: "/web/login"))
        protected.get("logout", use: logout)
        protected.get("init", use: index)
    }

    func loginInit(_ req:Request) throws -> EventLoopFuture<View> {
        req.view.render("login")
    }
    
    
    func loginWeb(_ req:Request) throws -> Response {
        req.redirect(to: "/web/init")
    }
    
    func logout(req:Request) throws -> Response {
        req.auth.logout(UsersApp.self)
        req.session.unauthenticate(UsersApp.self)
        return req.redirect(to: "/web/login")
    }
    
    func index(_ req:Request) throws -> EventLoopFuture<View> {
        let user = req.auth.get(UsersApp.self)!
        return req.view.render("init", ["username": "\(user.email)"])
    }

}
