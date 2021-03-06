//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ReactorActionDispatcher<R: Reactor>: Publisher {
    public typealias Output = AnyTask<Void, Error>.Output
    public typealias Failure = AnyTask<Void, Error>.Failure
    
    public let reactor: R
    public let action: R.Action
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        dispatch().receive(subscriber: subscriber)
    }
    
    public func dispatch() -> AnyTask<Void, Error> {
        var task = reactor.task(for: action)
        
        task.receive(.init(wrappedValue: self.reactor))
        
        reactor
            .environment
            .intercepts(for: action)
            .forEach { override in
                task = override.provide(for: action, task: task)
                task.receive(.init(wrappedValue: self.reactor))
            }
        
        task.taskIdentifier = action.createTaskIdentifier()
        reactor.environment.taskPipeline.track(task)
        task.start()
        
        return task.eraseToAnyTask()
    }
}

// MARK: - Auxiliary Implementation -

extension Reactor {
    public func dispatcher(for action: Action) -> ReactorActionDispatcher<Self> {
        ReactorActionDispatcher(reactor: self, action: action)
    }
    
    @discardableResult
    public func dispatch(_ action: Action) -> AnyTask<Void, Error> {
        dispatcher(for: action).dispatch()
    }
}

extension ViewReactor {
    @discardableResult
    public func dispatch(super action: _opaque_ReactorAction) -> AnyTask<Void, Error>  {
        environment.environment.viewReactors.dispatch(action)
    }
}

extension Reactor where Plan == EmptyReactorPlan {
    public func dispatcher(for plan: Plan) -> ReactorActionDispatcher<Self> {
        
    }
    
    @discardableResult
    public func dispatch(_ plan: Plan) -> AnyTask<Void, Error> {
        
    }
}

extension ViewReactor {
    public func environmentDispatch(_ action: _opaque_ReactorAction) -> AnyTask<Void, Error> {
        environment.environment.viewReactors.dispatch(action)
    }
}
