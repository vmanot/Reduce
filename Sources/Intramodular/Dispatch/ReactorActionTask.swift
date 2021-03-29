//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class ReactorActionTask<R: Reactor>: ParametrizedPassthroughTask<ReactorReference<R>, Void, Error>, ExpressibleByNilLiteral {
    public required convenience init(nilLiteral: ()) {
        self.init(action: { })
    }
    
    override public func didSend(status: Status) {
        try! withInput {
            if let action = taskIdentifier._cast(to: R.Action.self) {
                $0.wrappedValue.handleStatus(status, for: action)
            }
        }
    }
}

// MARK: - API -

extension ParametrizedPassthroughTask {
    public func withReactor<R: Reactor>(
        _ body: (R) throws -> ()
    ) rethrows -> Void where Input == ReactorReference<R> {
        if let input = input {
            try body(input.wrappedValue)
        } else {
            assertionFailure()
        }
    }
}

extension ReactorActionTask {
    public class func error(description: String) -> Self {
        .init { attemptToFulfill in
            attemptToFulfill(.failure(ReactorActionTaskError.custom(description)))
        }
    }
}

// MARK: - API -

extension Publisher {
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        .init(publisher: mapTo(()).eraseError())
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
enum ReactorActionTaskError: Error {
    case custom(String)
}
