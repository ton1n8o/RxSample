//
//  ViewController.swift
//  RxSample
//
//  Created by Antonio on 6/14/20.
//  Copyright © 2020 Antonio Carlos. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {

    private var bag = DisposeBag()
    let buttontTaps = PublishSubject<Void>()

    @IBOutlet var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        button.rx.tap
            .bind(to: buttontTaps)
            .disposed(by: bag)

        fetchData().subscribe(onNext: { userNames in

            userNames.forEach {
                print($0)
            }

        }, onError: { errors in
            print("\(errors)")
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
            .disposed(by: bag)
    }



    private func fetchData() -> Observable<[String]> {

        return buttontTaps.flatMapLatest {
            self.fetchUsers().flatMap { user -> Observable<[String]> in
                .just(user.map{ $0.name })
            }
        }
    }

    private func fetchUsers() -> Observable<[User]> {

        return Observable.create { observer in

            let users = [
                User(name: "Antonio"),
                User(name: "Lucas")
            ]

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                observer.onNext(users)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }
}

struct User {
    let name: String
}

