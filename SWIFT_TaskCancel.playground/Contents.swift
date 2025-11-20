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
    
    let _ = await task.value
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
