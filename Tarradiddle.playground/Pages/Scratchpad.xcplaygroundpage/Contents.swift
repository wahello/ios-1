// for testing things out

import RxSwift

Observable.from(["hello", "darkness", "my", "old", "friend"])
  .map { $0.uppercased() }
  .subscribe(onNext: { print($0) })

import Apollo
import RxApollo

let apollo = ApolloClient(url: URL(string: "http://localhost:4000/graphql")!)
apollo.rx.perform(mutation: <#T##GraphQLMutation#>)
