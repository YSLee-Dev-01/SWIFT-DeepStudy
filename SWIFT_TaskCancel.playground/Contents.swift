import Foundation
import PlaygroundSupport

/// Task.cancel()
///
/// 진행 중인 Task에 cancel()을 호출하더라도, task.value는 여전히 값을 받을 수 있음
/// - Task 내부 await 함수가 취소되더라도 하단의 구문은 그대로 실행됨
/// -> 실행을 막고 싶을 경우 Task.isCancelled로 확인 후 return 해야함
///
/// Task.cancel()
/// - 협력적 취소 메커니즘을 사용함
/// -> Task가 cancel 된 경우 내부 함수도 취소를 감지하고 요청을 중단함
///
/// - URLSession, Task.sleep 등은 명시적 취소를 자동으로 지원함
/// -> 취소된 경우 에러를 리턴함
/// -> Task.sleep에서 try를 사용하는 이유도 cancel 된 경우 에러를 리턴 후 sleep 하지 않기 때문
///
/// + Actor의 순차접근은 Task.cancel()로 취소되지 않음
///
/// = Task.cancel()은 취소 개념이며, await 함수에 따라 실행을 취소하고 에러를 리턴하지만,
/// 하단 구문의 실행을 막지는 않음
///
/// + Task.cancel() 자체는 하단 구문의 실행을 막지는 않지만,
/// await 함수가 CancellationError를 throw 하면
/// 에러 처리가 없는 경우 종료될 수 있음 (하단 구문 실행이 되지 않을 수 있음) (에러에 의한 종료)
///
/// + Task가 비구조화적으로 중첩되어 있을 때 부모 Task가 cancel() 된다고 해서 자식 Task까지 cancel() 되는 것은 아님
/// - 비구조화적인 Task이기 때문 (우선순위, context 등은 상속 받음) (자세한 공부는 TaskGroup에서 진행!)
///
/// withTaskCancellationHandler
/// - task가 cancel 되었을 때 특정 클로저를 실행시키고 싶을 때 사용하는 함수
/// - Task.cancel()을 실행하더라도 명시적 취소를 지원하지 않는 경우 취소를 감지하지 않기 때문에 함수가 계속 진행됨
/// -> withTaskCancellationHandler는 task의 cancel 이벤트를 감지하고, onCancel 클로저를 통해 취소를 전달할 수 있음
/// 클로저 내부에서 await로 작업을 진행 중일 때 cancel을 감지함
/// - 이미 클로저를 벗어난 경우에는 (작업이 끝난 경우) 감지하지 않음

/// 예제별로 주석을 풀어서 확인하기!

// async await 사용 제약 해제
PlaygroundPage.current.needsIndefiniteExecution = true

print("1️⃣ 첫 번째 예제")
class TaskManager {
    func task() async -> Bool {
        print("🎬 Task 함수 실행")
        for index in 1 ... 5 {
            do {
                try await Task.sleep(for: .seconds(1))
                print("✅ Task.sleep 진행됨")
            } catch {
                print("⚠️ Task.sleep 되지 않음", error)
            }
            print("🕐 \(index)번째 실행")
        }
        return true
    }
}

Task {
    let manager = TaskManager()
    
    let task = Task {
        await manager.task()
    }
    
    Task {
        try? await Task.sleep(for: .seconds(2))
        print("✋ task.cancel() 호출")
        task.cancel()
    }
    
    print("🔚 Task 함수 종료")
}

/// 3번째 실행부터는 Task가 cancel되어 sleep 되지 않음

//print("2️⃣ 두 번째 예제")
//actor SettingManager {
//    private var isDarkMode = false
//    
//    func setDarkMode(_ isDarkMode: Bool) -> Bool{
//        self.isDarkMode = isDarkMode
//        print("🔄 DarkMode 설정: \(isDarkMode)")
//        
//        return isDarkMode
//    }
//}
//
//Task {
//    let manager = SettingManager()
//    
//    let task = Task {
//        var result: [Bool] = []
//        for index in 1 ... 5 {
//            result.append(await manager.setDarkMode(index % 2 == 0))
//        }
//        return result
//    }
//    
//    Task {
//        print("✋ task.cancel() 호출")
//        task.cancel()
//    }
//    
//    let taskResult = await task.value
//    print("🔚 Task 함수 종료", taskResult)
//}
//
///// task.cancel은 actor의 접근을 취소하지는 않음

//print("3️⃣ 세 번째 예제")
//let parentTask = Task {
//    print("🎬 👨 부모 Task 시작")
//    
//    let childTask = Task {
//        print("🎬 👶 자식 Task 시작")
//        
//        for i in 1...5 {
//            try? await Task.sleep(for: .milliseconds(900))
//            print("👶 자식 - \(i)")
//        }
//        
//        print("🔚 👶 자식 Task 종료")
//    }
//    
//    try? await Task.sleep(for: .seconds(5))
//    print("🔚 👨 부모 Task 완료")
//}
//
//Task {
//    try await Task.sleep(for: .seconds(2))
//    print("✋ 부모 Task.cancel() 호출")
//    parentTask.cancel()
//}

//print("4️⃣ 네 번째 예제")
//
//var workItem: DispatchWorkItem?
//let task = Task {
//    print("🎬 Task 시작")
//    
//    await withTaskCancellationHandler {
//        workItem = DispatchWorkItem {
//            print("💬 타이머 실행됨")
//        }
//        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: workItem!)
//        
//        try? await Task.sleep(for: .seconds(5)) // 클로저 내부에서 정지하도록 대기
//    } onCancel: {
//        print("⏰ 타이머 종료")
//        workItem?.cancel()
//    }
//    
//    print("🔚 Task 종료")
//}
//
//Task {
//    try? await Task.sleep(for: .seconds(1))
//    print("✋ task.cancel() 호출")
//    task.cancel()
//}
