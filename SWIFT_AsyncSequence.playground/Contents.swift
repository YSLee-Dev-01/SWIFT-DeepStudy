import Foundation
import PlaygroundSupport

/// AsyncSequence
///
/// Sequence?
/// - 프로토콜 중 하나로 한번에 하나씩 단계별로 값을 진행할 수 있는 목록을 가짐
///
/// Collection
/// - 프로토콜 중 하나로 Sequence를 채택하고 있음
/// - 여러번 순회를 여러번 보장하며, 인덱스로 접근이 가능함
/// -> Sequence는 인덱스 접근을 제공하지 않으며, 여러번 순회가 불가능함 (별도 처리 없이는)
/// - Swift의 배열, Set, 딕셔너리가 채택하고 있음
///
/// for를 통해 loop를 돌고 싶을 때는 Sequence을 채택하고 있어야 함
/// - Sequence 프로토콜은 makeIterator() 구현을 요구함
/// - makeIterator()는 IteratorProtocol를 채택하는 타입을 return 해야함
/// -> IteratorProtocol 프로토콜를 객체가 채택하거나, IteratorProtocol 프로토콜을 채택하는 객체를 return 해야함
/// -> 객체가 IteratorProtocol를 채택하면 makeIterator()는 자동으로 self를 리턴함
///
/// IteratorProtocol
/// - next() 구현을 요구함
/// -> 한개씩 요소를 반환할 때 사용되는 메서드
/// - nil를 리턴하면 루프가 종료된다는 의미
///
/// For를 사용한 경우 내부에서는 아래와 같은 처리가 발생함
/// let array = [1, 2, 3]
/// for item in array {}
///
/// var iterator = array.arr.makeIterator()
/// while let item = iterator.next() {}
///
/// -> 내부에서는 while 구문을 사용하게 됨

/// struct으로 Sequence를 사용할 경우 여러번 순회처리가 불가함을 볼 수 없음
/// - makeIterator()를 호출 시 self를 반환하게 되는데,
/// 이 때 struct은 복사본을 반환하기 때문에 currentValue가 0부터 다시 시작하게 됨
/// -> class는 참조 주소를 전달하기 때문에 0부터 다시 시작하지 않음
class MySequence: Sequence, IteratorProtocol {
    private var currentValue = 0
    
    func next() -> Int? {
        self.currentValue += 1
        return self.currentValue >= 4 ? nil :  self.currentValue
    }
}

enum MyError: Error {
    case example
}

//print("1️⃣ 첫 번째 예제")
//let collection = [1, 2, 3]
//let mySequence = MySequence()
//
//for value in mySequence {
//    print("1️⃣ for - mySequence", value)
//}
//
//for value in mySequence {
//    print("2️⃣ for - mySequence", value) // 순회가 안되기 때문에 값이 없음
//}

// print(mySequence[0]) // 오류 발생

/// AsyncSequence
/// - Sequence와 유사하지만 비동기성을 추가함
/// -> 한번에 하나씩 단계별로 값을 진행하는 목록을 제공하면서, 비동기 성을 추가함
/// - for 사용이 가능
/// -> 비동기 성이 있기 때문에 await와 함께 사용하며, 에러를 내뱉는 경우 try와 동시 사용도 가능함
/// -> Sequence는 에러를 내뱉을 수 없음
///
/// AsyncSequence 채택 시
/// - IteratorProtocol이 아닌 AsyncIteratorProtocol를 채택해야함
/// - next() 뿐만 아니라 makeAsyncIterator()도 구현해야함
///
/// + AsyncSequence는 next()에서 nil이 리턴됐을 때, 에러가 반환됐을 때 루프가 종료됨
/// (Task.cancel로 루프를 중단시킬 수 없음)
/// + AsyncSequence와 Sequence는 map, filter, reduce 와 같은 고차함수 사용이 가능함

//print("2️⃣ 두 번째 예제")
//struct MyAsyncSequence: AsyncSequence, AsyncIteratorProtocol {
//    private var currentValue = 0
//    
//    mutating func next()  async throws -> Int? {
//        try? await Task.sleep(for: .milliseconds(500))
//        self.currentValue += 1
//        if self.currentValue > 5 {
//            throw MyError.example
//        }
//        
//        return self.currentValue
//    }
//    
//    func makeAsyncIterator() -> MyAsyncSequence {
//        return self
//    }
//}
//
//let myAsyncSequence = MyAsyncSequence()
//let task = Task {
//    do {
//        for try await value in myAsyncSequence
//            .map {"3️⃣ for - myAsyncSequence \($0)"}{
//                print(value)
//            }
//    } catch {
//        print("⚠️에러 발생", error.localizedDescription)
//    }
//}
//
//Task {
//    await try? await Task.sleep(for: .milliseconds(1000))
//    await task.cancel() // task.cancel()은 루프를 중단시킬 수 없음 (Task.sleep만 중단)
//}

/// AsyncStream
/// - 순서가 있고, 비동기적으로 생성된 요소의 Sequence
/// -> AsyncSequence를 생성할 때 사용하는 구조체
/// -> AsyncSequence를 더 쉽게 만들어서 사용할 수 있게 함
///
/// 기본 AsyncStream는 에러를 내뱉지 못함
/// - 에러를 내뱉으려면 AsyncThrowingStream를 사용함
///
/// 사용방법
/// 1. AsyncStream에 타입을 지정
/// 2. 클로저 내부에서 continuation 파라미터를 통해 값, 에러, 완료 여부를 전달
///
/// continuation 종류
/// yield
/// - 스트림에게 값을 제공할 때 사용
///
/// finish
/// - 스트림을 종료할 때 사용
/// - 에러를 내뱉는 경우 finish(throing:)
///
/// onTermination
/// - 스트림이 종료될 때 호출되는 클로저
/// - termination 매개변수를 통해 스트림이 종료됐을 때, Task가 cancel 되었을 때를 판단할 수 있음
/// - continuation.onTermination(.cancelled) 같은 형태로 수동 호출 가능
/// - 스트림 생명주기에서 1번만 호출됨

print("3️⃣ 세 번째 예제")
let stream = AsyncThrowingStream<String, Error>() { continuation in
    let task = Task {
        for char in ["가", "나", "다", "라", "마"] {
            try Task.checkCancellation()
            try await Task.sleep(for: .seconds(1))
            continuation.yield(char)
        }
        print("🔚 ✅ 스트림 종료 호출")
        continuation.finish()
    }
    
    continuation.onTermination = {  termination in
        switch termination {
        case .finished:
            print("🔚 스트림 종료") // 이미 취소 요청의 print가 불렸기 때문에 호출되지 않음
        case .cancelled:
            print("🗑️ Task 취소")
        }
        task.cancel() // 외부 Task가 중단되었다고 해도 내부 Task는 중단되지 않기 때문에 명시적으로 취소 해야함
    }
}

let task = Task {
    do {
        for try await char in stream {
            print("for - char", char)
        }
    } catch {
        print("⚠️ 외부 Task 에러 발생", error.localizedDescription)
    }
    print("🔚 💬 For 종료")
}

Task {
    try await Task.sleep(for: .milliseconds(1500))
    print("✋ 스트림 취소 요청")
    task.cancel()
}

/// 결과는 아래와 같음
//3️⃣ 세 번째 예제
//for - char 가
//✋ 스트림 취소 요청
//🗑️ Task 취소
//🔚 💬 For 종료

/// 1. task 블록을 만나서 stream 구독함
/// 2. 2초 뒤 구독 중인 stream의 외부 task를 취소함
/// 3. onTermination의 콜백 메소드가 호출되며, 스트림을 취소함
/// 4. 내부의 task의 cancel()를 호출
/// - 내부 Task의 cancel을 요청하지 않으면 내부 Task는 계속 실행됨
/// -> 부모와 다른 독립적인 Task이기 때문 (부모자식 관계를 만들려면 TaskGroup 등 사용)
/// 5. 다음 for 루프에서 Task.checkCancellation()가 오류를 발생시킴에 따라 내부 Task 자체가 중단됨
/// - for 뿐만 아니라 하단의 print 문도 호출되지 않음 (throw가 발생했기 때문)
/// 6. 외부 Task의 await 하단 print 구문 실행
///
/// 에러 print가 뜨지 않는 이유
/// - 내부 Task에서 에러가 발생했는데, 이를 처리하는 로직이 없기 때문
/// -> task.value 등으로 처리 하지 않았기 때문에 Task 자체가 그냥 종료됨
