//
//  StaticLibraryProject.swift
//  StaticLibraryProject
//
//  Created by 吴天 on 2025/11/22.
//

public struct Wrapper<Value> {
  private var value: Value

  /// The wrapped object.
  public var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }
}

public class StaticLibraryProject {
    public var someBool: Bool = true
    
    public init() {}
}
