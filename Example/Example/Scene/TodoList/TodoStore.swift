//
//  Core-CleanSwift-ExampleInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/15/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxCoreRedux
import RxCoreList

class TodoStore: Store<TodoReducer.Action, TodoReducer.State> {
    init() {
        super.init(reducer: TodoReducer(), initialState: Todo.State())
        inject(
            TodoListEpic().apply,
            TodoCreateEpic().apply,
            {
                dispatcher, _, _ in
                dispatcher
                    .of(type: .logout)
                    .map {
                        _ in
                        AppPreferences.instance.token = nil
                        return Action(type: .logoutSuccess, payload: 0)
                }
            }
        )
    }
}

enum TodoActionType: String, ListActionType {
    static var updateListState: TodoActionType {
        return ._updateListState
    }
    static var load: TodoActionType {
        return ._load
    }
    static var receiveError: TodoActionType {
        return ._receiveError
    }
    
    case _updateListState
    case _load
    case _receiveError

    case createTodo
    case selectTodo

    case logout
    case logoutSuccess
}

extension Payload.List {
    struct Request: PayloadListRequestable {
        let page: Int
        let count: Int
        let isAutoRequestCounting: Bool
        let cancelRunning: Bool
        
        init(page: Int, count: Int = 10, isAutoRequestCounting: Bool = true, cancelRunning: Bool) {
            self.page = page
            self.count = count
            self.isAutoRequestCounting = isAutoRequestCounting
            self.cancelRunning = cancelRunning
        }
    }
}
