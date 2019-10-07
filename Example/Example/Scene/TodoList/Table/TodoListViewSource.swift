//
//  Core-CleanSwift-ExampleViewModel.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/13/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase
import RxCoreList
import DifferenceKit

class TodoListViewSource: BaseTableViewSource {
    weak var store: TodoStore?
    
    init(store: TodoStore?) {
        self.store = store
        let cell = DefaultCellModel(type: .nib(nibName: "TodoTableViewCell", bundle: nil))
        cell.height = 80
        let sectionModels: [DefaultSectionModel] = [
            .init(cells: [ cell ])
        ]
        super.init(sections: sectionModels, shouldAnimateLoading: true)
        
        store?.state
            .filter { $0.error == nil && !$0.isLogout }
            .map { $0.list }
            .distinctUntilChanged()
            .map {
                response in
                if response.currentPage == 0 {
                    return ListViewSourceModel(type: .initial, data: response.data, needsReload: true)
                } else {
                    return ListViewSourceModel(type: .addNew(at: .end(length: response.data.count)), data: response.data, needsReload: true)
                }
            }
            .bind(to: modelRelay)
            .disposed(by: disposeBag)
    }
    
    override func bind(value: ViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath) {
        let item = value as! TodoEntity
        let dataCell = cell as! TodoTableViewCell
        
        dataCell.lbTime.text = item.createdAt.toISO()
        dataCell.lbTitle.text = item.title
    }
    
    override func objects(in section: SectionModel, at index: Int, onChanged type: ListModelChangeType) -> [AnyDifferentiable] {
        if let models = models(forIdentifier: "default") {
            return models.map { $0.toAnyDifferentiable() }
        }
        
        return super.objects(in: section, at: index, onChanged: type)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store?.dispatch(type: .selectTodo, payload: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? LoadingAnimatable else {
            return
        }
        cell.startAnimation()
        
        let currentPage = store?.currentState.list.currentPage ?? 0
        store?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
    }
}
