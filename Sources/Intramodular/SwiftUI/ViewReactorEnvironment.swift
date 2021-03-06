//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI

@propertyWrapper
public struct ViewReactorEnvironment: DynamicProperty, ReactorEnvironment {
    @usableFromInline
    @Environment(\.self) var environment
    @inlinable
    @ObservedObject public internal(set) var taskPipeline: TaskPipeline
    @inlinable
    @State public internal(set) var dispatchIntercepts: [ReactorDispatchIntercept] = []
    @usableFromInline
    @State var environmentBuilder = EnvironmentBuilder()
    @usableFromInline
    @State var isSetup: Bool = false
    
    public var wrappedValue: Self {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init() {
        taskPipeline = .init()
    }

    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        guard !isSetup else {
            return
        }
        
        reactor.wrappedValue.coordinator.environmentBuilder.insertReactor(reactor)
    }
}
