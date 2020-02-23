import ComposableArchitecture
import PrimeModal
import SwiftUI

#if os(macOS)
public struct CounterView: View {
  struct State: Equatable {
    let alertNthPrime: PrimeAlert?
    let count: Int
    let isNthPrimeButtonDisabled: Bool
    let isPrimeModalShown: Bool
    let nthPrimeButtonTitle: LocalizedStringKey
    let isPrimePopover: IsPrimeDetail?
  }
  enum Action {
    case decrTapped
    case incrTapped
    case nthPrimeButtonTapped
    case alertDismissButtonTapped
    case isPrimeButtonTapped
    case primePopoverDismissed
    case doubleTap
  }

  @ObservedObject var viewStore: ViewStore<State, Action>
  let store: Store<CounterViewState, CounterViewAction>

  public init(store: Store<CounterViewState, CounterViewAction>) {
    print("CounterView.init")
    self.store = store
    self.viewStore = self.store
      .scope(value: State.init(counterViewState:), action: Action.from(counterViewAction:))
      .view(removeDuplicates: ==)
  }

  public var body: some View {
    print("CounterView.body")
    return VStack {
      HStack {
        Button("-") { self.viewStore.send(.decrTapped) }
        Text("\(self.viewStore.value.count)")
        Button("+") { self.viewStore.send(.incrTapped) }
      }
      Button("Is this prime?") { self.viewStore.send(.isPrimeButtonTapped) }
      Button(self.viewStore.value.nthPrimeButtonTitle) {
        self.viewStore.send(.nthPrimeButtonTapped)
      }
      .disabled(self.viewStore.value.isNthPrimeButtonDisabled)
    }
    .font(.title)
    .popover(
      item: Binding(
        get: { self.viewStore.value.isPrimePopover },
        set: { _ in self.viewStore.send(.primePopoverDismissed) }
      )
      ) { isPrimeDetail in
        IsPrimeModalView(
          store: self.store.scope(
            value: { (isPrimeDetail.count, $0.favoritePrimes) },
            action: { .primeModal($0) }
          )
        )
    }
    .alert(
      item: .constant(self.viewStore.value.alertNthPrime)
    ) { alert in
      Alert(
        title: Text("The \(ordinal(self.viewStore.value.count)) prime is \(alert.prime)"),
        dismissButton: .default(Text("Ok")) {
          self.viewStore.send(.alertDismissButtonTapped)
        }
      )
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    .background(Color.white)
    .onTapGesture(count: 2) {
      self.viewStore.send(.doubleTap)
    }
    .foregroundColor(Color.black)
  }
}

extension CounterView.State {
  init(counterViewState state: CounterViewState) {
    self.alertNthPrime = state.alertNthPrime
    self.count = state.count
    self.isNthPrimeButtonDisabled = state.isNthPrimeRequestInFlight
    self.isPrimeModalShown = state.isPrimeModalShown
    self.nthPrimeButtonTitle = "What is the \(ordinal(state.count)) prime?"
    self.isPrimePopover = state.isPrimeDetail
  }
}

extension CounterView.Action {
  static func from(counterViewAction action: CounterView.Action) -> CounterViewAction {
    switch action {
    case .decrTapped:
      return .counter(.decrTapped)
    case .incrTapped:
      return .counter(.incrTapped)
    case .nthPrimeButtonTapped:
      return .counter(.requestNthPrime)
    case .alertDismissButtonTapped:
      return .counter(.alertDismissButtonTapped)
    case .isPrimeButtonTapped:
      return .counter(.isPrimeButtonTapped)
    case .primePopoverDismissed:
      return .counter(.primeModalDismissed)
    case .doubleTap:
      return .counter(.requestNthPrime)
    }
  }
}
#endif