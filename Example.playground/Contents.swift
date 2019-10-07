import CoreRedux
import RxSwift

struct ExAction: Actionable {
    enum `Type`: String {
        case a
        case b
        case c
        case d
    }
    
    let type: ExAction.`Type`
    let payload: Any
}

struct ExState: Statable {
    let i: Int
}

class ExStore: Store<ExReducer> {
    init() {
        super.init(reducer: .init(), initialState: .init(i: 0))
        inject(
            {
                dispatcher, actionStream, _ in
                dispatcher
                    .of(type: .a)
                    .takeUntil(actionStream.of(type: .d))
                    .map { $0.payload as! Int }
                    .flatMap {
                        i -> Observable<Action> in
                        .concat(
                            .just(ExAction(type: .b, payload: i + 1)),
                            .just(ExAction(type: .d, payload: i + 1))
                        )
//                        .from([
//                            ExAction(type: .b, payload: i + 1),
//                            ExAction(type: .d, payload: i + 1)
//                        ])
                    }
            },
            {
                dispatcher, _, _ in
                dispatcher
                    .of(type: .b)
                    .map {
                        _ in .init(type: .c, payload: 1)
                    }
            }
        )
    }
}

class ExReducer: Reducable {
    typealias Action = ExAction
    typealias State = ExState
    
    func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .b:
            return State(i: currentState.i + (action.payload as! Int))
        case .c:
            return State(i: currentState.i + (action.payload as! Int))
        default:
            return currentState
        }
    }
}

let store = ExStore()
store.activate()

store.dispatch(type: .a, payload: 0)
