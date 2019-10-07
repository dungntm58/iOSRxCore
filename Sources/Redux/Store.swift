//
//  Store.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift
import RxRelay

open class Store<Reducer>: Storable, Dispatchable where Reducer: Reducable {
    public typealias State = Reducer.State
    public typealias Action = Reducer.Action

    private lazy var _disposables = CompositeDisposable()
    private lazy var _disposeBag = DisposeBag()
    private let _state: BehaviorRelay<State>
    private let _action: PublishRelay<Action>
    private let _dispatcher: PublishRelay<Action>
    private let _reducer: Reducer
    private var _epics: [EpicFunction<Action, State>]

    private(set) public var isActive: Bool

    public var currentState: State {
        return _state.value
    }

    public var state: Observable<State> {
        return _state.asObservable().distinctUntilChanged { $0 as AnyObject === $1 as AnyObject }
    }

    public init(reducer: Reducer, initialState: State) {
        _state = BehaviorRelay(value: initialState)
        _action = PublishRelay()
        _dispatcher = PublishRelay()
        _reducer = reducer
        _epics = []

        isActive = false
        run()
    }

    public func activate() {
        isActive = true
    }

    public func deactivate() {
        isActive = false
    }

    public func dispatch(type: Action.ActionType, payload: Any) {
        dispatch(Action(type: type, payload: payload))
    }

    public func dispatch(_ action: Action...) {
        dispatch(action)
    }

    public func dispatch(_ actions: [Action]) {
        for act in actions {
            _dispatcher.accept(act)
        }
    }

    public func inject(_ epic: EpicFunction<Action, State>...) {
        self.inject(epic)
    }

    public func inject(_ epics: [EpicFunction<Action, State>]) {
        self._epics = epics
    }

    private func run() {
        _ = _disposables.insert(
            _dispatcher.bind(to: _action)
        )
        let newDispatch = _dispatcher
            .flatMap {
                [weak self] action -> Observable<Action> in
                guard let `self` = self, self.isActive else { return .empty() }
                if self._epics.isEmpty { return .just(action) }
                return .merge(self._epics.map { $0(.just(action), self._action.asObservable(), self._state.asObservable()) })
            }
            .share()
        _ = _disposables.insert(
            newDispatch.bind(to: _action)
        )
        _ = _disposables.insert(
            newDispatch
                .subscribe(onNext: {
                    [weak self] action in
                    guard let `self` = self else { return }
                    _ = self._disposables.insert(
                        Observable.just(action)
                            .flatMap {
                                [weak self] action -> Observable<Action> in
                                guard let `self` = self, self.isActive else { return .empty() }
                                if self._epics.isEmpty { return .just(action) }
                                return .merge(self._epics.map { $0(.just(action), self._action.asObservable(), self._state.asObservable()) })
                            }
                            .share()
                            .bind(to: self._action)
                    )
                })
        )
        _ = _disposables.insert(
            _action
                .withLatestFrom(_state) {
                    [_reducer] action, state -> (Action, State) in
                    let newState = _reducer.reduce(action: action, currentState: state)
                    #if DEBUG
                    Swift.print("Previous state:", state)
                    Swift.print("Action:", action)
                    Swift.print("Next state:", newState)
                    #endif
                    return (action, newState)
                }
                .map { $0.1 }
                .bind(to: _state)
        )
        _disposables.disposed(by: _disposeBag)
    }
}
