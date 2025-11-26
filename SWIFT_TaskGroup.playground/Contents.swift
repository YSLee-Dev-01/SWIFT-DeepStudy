import Foundation
import PlaygroundSupport

/// TaskGroup
///
/// Swift의 Concurrency는 Structured, Unstructured Concurrency로 나눌 수 있음
/// - 구조화된, 구조화 되지 않은 동시성
/// - 애플은 구조화된 동시성을 권장함
///
/// Unstructured
/// - 부모/자식 관계를 가지지 않으며, 생성된 Context 보다 더 오래 있을 수 있는 Task
/// - 각 Task마다 독립적인 생명주기를 가짐
/// -> Task, Task.detached
///
/// Structured
/// - 부모/자식 관계를 가지며, 부모 Task가 자식 Task의 완료를 기다리며, 부모 Task가 종료되면 자식 Task도 종료됨
/// - 자식 Task는 부모 Task 보다 오래 존재할 수 없음 (스코프가 종료되면 자동 종료)
/// -> TaskGroup, async let
///
/// Task
/// - Unstructured
/// - 부모 Task의 Context, TaskLocal, 우선순위를 상속받음
/// - 부모의 취소, 완료에는 대응하지 않음
/// -> Task 내부에서 Task를 사용하는 것도 Unstructured
///
/// Task.detached
/// - Unstructured
/// - 부모 Task의 Context, TaskLocal, 우선순위를 상속받지 않으며, 부모의 취소/완료에도 대응하지 않음
/// -> 완전히 다른 Task에서 작업 되어야 할 때 사용
///
/// TaskGroup
/// - Structured
/// - 부모 Task의 Context, TaskLocal, 우선순위를 상속받으며, 부모의 취소/완료에 대응함
/// -> 확정할 수 없는 개수의 Task를 병렬 실행할 때 사용
/// - withTaskGroup, withThrowingTaskGroup으로 제작
///
/// async let
/// - Structured
/// - 부모 Task의 Context, TaskLocal, 우선순위를 상속받으며, 부모의 취소/완료에 대응함
/// -> 고정된 개수의 Task를 병렬 실행할 때 사용
///
/// TaskGroup VS async let
/// - TaskGroup은 확정할 수 없는 배열과 같은 데이터를 병렬 실행할 때 사용
/// -> 모든 자식 Task는 같은 값을 내뱉어야 함
/// -> 완료되는 순서대로 처리할 수 있음
/// - AsyncSequence를 채택하고 있음
///
/// - async let은 고정된 개수의 Task를 병렬 실행할 때 사용
/// -> 선언 즉시 Task를 실행하며, await 시점에서 데이터를 기다림
/// -> await 선언 부분에 따라 먼저 받는 데이터가 달라짐
/// -> 리턴 값이 다른 여러 함수를 동시에 사용할 수 있음

//print("1️⃣ 첫 번째 예제")
//let parentTask = Task(priority: .high) {
//    print("🧑🏻 부모 Task 시작, 우선순위: \(Task.currentPriority)")
//    
//    Task {
//        print("👦🏻 자식 Task 시작, 우선순위: \(Task.currentPriority)")
//        
//        for i in 1 ... 5 {
//            try await Task.sleep(for: .milliseconds(500))
//            print("👦🏻 자식 Task 진행 중 - \(i)/5, 자식 Task 취소 여부: \(Task.isCancelled)")
//        }
//        
//        print("👦🏻 자식 Task 종료")
//    }
//    
//    Task.detached {
//        print("🐶 자식2 Task 시작, Task 우선순위: \(Task.currentPriority)")
//        try await Task.sleep(for: .seconds(3))
//        print("🐶 자식2 Task 종료, Task 취소 여부: \(Task.isCancelled)")
//    }
//    
//    try? await Task.sleep(for: .seconds(3))
//    print("🧑🏻 부모 Task 종료, 부모 Task 취소 여부: \(Task.isCancelled)")
//}
//
//Task {
//    try await Task.sleep(for: .seconds(1))
//    print("✋ 부모 Task.cancel 호출")
//    parentTask.cancel()
//}

//print("2️⃣ 두 번째 예제")
//func createGroupTask(_ valueList: [Int]) async throws {
//    try await withThrowingTaskGroup(of: Int.self) { group in
//        print("🎬 Task 시작")
//        for value in valueList.enumerated() {
//            group.addTask {
//                try await Task.sleep(for: .milliseconds(2500 - (value.offset * 100)))
//                return value.element
//            }
//        }
//        
//        while let item = try await group.next() { // AsyncSequence를 채택하고 있음
//            print("💬 Group 데이터 - \(item)")
//        }
//        print("🔚 Task 종료")
//    }
//}
//
//let task = Task {
//    do {
//        try await createGroupTask([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
//    } catch {
//        print("⚠️ 오류 발생", error)
//    }
//}
//
//Task {
//    try? await Task.sleep(for: .milliseconds(2000))
//    print("✋ Task.cancel 호출")
//    task.cancel()
//}

print("3️⃣ 세 번째 예제")
func createTask(waitMilliseconds: Int, id: String) async throws -> String {
    print("🕐 \(id) 작업 대기")
    try await Task.sleep(for: .milliseconds(waitMilliseconds))
    return "✅ " + id + " 작업 완료"
}

let task = Task {
    print("🎬 부모 Task 시작")
    
    async let task1 = createTask(waitMilliseconds: 1000, id: "1️⃣")
    async let task2 = createTask(waitMilliseconds: 2000, id: "2️⃣")
    async let task3 = createTask(waitMilliseconds: 3000, id: "3️⃣")
    async let task4 = createTask(waitMilliseconds: 10000, id: "4️⃣")
    
    do {
        print(try await task3)
        print(try await task2)
        print(try await task1)
        
        print(try await task4)
    } catch {
        print("⚠️ 오류 발생", error)
    }
    
    print("🔚 부모 Task 종료")
}

Task {
    try? await Task.sleep(for: .milliseconds(4000))
    print("✋ Task.cancel 호출")
    task.cancel()
}

/// 실행 순서
/// 1. createTask() 호출 시 바로 비동기 작업이 실행됨
/// 2. await 시점에서 해당 값을 대기함
/// - task 1, 2, 3 중 3번째가 가장 오래걸리는 작업인데 await를 첫번째로 기다리기 때문에
/// task3를 기다린 후 2, 1이 연달아 바로 리턴됨 (즉시 반환)
/// 3. task 4는 실행은 되지만, 실행 도중 부모 task의 cancel로 인해 에러를 throw하고 catch 블록이 실행됨
