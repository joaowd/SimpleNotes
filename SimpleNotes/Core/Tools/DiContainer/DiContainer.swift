//
//  DiContainer.swift
//  SimpleNotes
//
//  Created by João Palma on 08/12/2019.
//  Copyright © 2019 João Palma. All rights reserved.
//

import Foundation

class DiContainer {
    fileprivate static var registrations = [AnyHashable : () -> Any]()
    fileprivate static var viewControllerRegistrations = [AnyHashable : () -> Any]()
    fileprivate static var lock = NSRecursiveLock()
    
    static func register<T>(_: T.Type, constructor: @escaping () -> Any) {
        let dependencyName = String(describing: T.self)
        registrations[dependencyName] = constructor
    }
    
    static func registerViewController<T>(_: T.Type, constructor: @escaping () -> Any) {
        let dependencyName = String(describing: T.self)
        viewControllerRegistrations[dependencyName] = constructor
    }
    
    static func registerAsSingleton<T>(_: T.Type, constructor: @escaping () -> Any) {
        let dependencyName = String(describing: T.self)
        var instance: Any?
        let resolver: () -> Any = {
            if instance == nil {
                instance = constructor()
                return instance!
            } else {
                return instance!
            }
        }
        registrations[dependencyName] = resolver
    }
    
    static func registerWeakSingleton<T>(_: T.Type, constructor: @escaping () -> AnyObject) {
        let dependencyName = String(describing: T.self)
        var instance: AnyObject?
        instance = nil
        let resolver: () -> AnyObject = { [weak instance] in
            if let instance = instance {
                return instance
            } else {
                let newInstance = threadSafe(constructor())
                instance = newInstance
                return newInstance
            }
        }
        registrations[dependencyName] = resolver
    }
    
    static func resolve<T>(type: T.Type = T.self) -> T {
        let dependencyName = String(describing: T.self)
        guard let resolver = registrations[dependencyName] else {
            fatalError("No registration for type \(dependencyName)")
        }
        guard let result = resolver() as? T else {
            fatalError("Can't cast registration to type \(dependencyName)")
        }
        return result
    }
    
    static func resolveViewController<T>(name: String) -> T {
        guard let resolver = viewControllerRegistrations[name] else {
            fatalError("No registration for type \(name)")
        }
        guard let result = resolver() as? T else {
            fatalError("Can't cast registration to type \(name)")
        }
        return result
    }
    
    static func remove<T>(type: T.Type) {
        let dependencyName = String(reflecting: T.self)
        registrations.removeValue(forKey: dependencyName)
    }
    
    fileprivate static func threadSafe<T>(_ closure: @autoclosure ()->T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return closure()
    }
}
