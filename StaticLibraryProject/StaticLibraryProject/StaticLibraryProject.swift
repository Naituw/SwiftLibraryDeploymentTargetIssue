//
//  StaticLibraryProject.swift
//  StaticLibraryProject
//
//  Created by 吴天 on 2025/11/22.
//

protocol MyProtocol {
    var someBool: Bool { get set }
}

public class StaticLibraryProject : MyProtocol {
    public var someBool: Bool = true
    
    public init() {}
}
