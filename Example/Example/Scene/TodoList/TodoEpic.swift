//
//  TodoInteractor.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 2/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxCoreBase
import RxCoreRedux
import RxCoreList
import RxSwift

class TodoListEpic: BaseListEpic<Todo.Action, Todo.State, TodoWorker> {
    init() {
        super.init(worker: TodoWorker())
    }
    
    override func toPaginationRequestOptions(from payload: PayloadListRequestable?) -> PaginationRequestOptions? {
        return payload as? PaginationRequestOptions
    }
}

extension Payload.List.Request: PaginationRequestOptions {
    var requestOptions: RequestOption? {
        return [
            "page": page
        ]
    }
    
    var repositoryOptions: RepositoryOption {
        return .default
    }
    
    var storeFetchOptions: DataStoreFetchOption {
        return .page(page, size: count, predicate: nil, sorting: .desc(property: "createdAt"), validate: true)
    }
}

class TodoCreateEpic: Epic {
    typealias Action = Todo.Action
    typealias State = Todo.State
    
    let worker: TodoWorker
    init() {
        self.worker = TodoWorker()
    }
    
    func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        return dispatcher
            .of(type: .createTodo)
            .compactMap { $0.payload as? String }
            .flatMap(worker.createNew)
            .map { Payload.List.Response(data: [$0]) }
            .map { $0.toAction() }
            .catchError { .just($0.toAction()) }
    }
}
