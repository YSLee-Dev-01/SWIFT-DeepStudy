import Foundation
import PlaygroundSupport

/// Continuation
///
/// - suspension point에서 실행 컨텍스트를 캡쳐하고, 나중에 그 시점부터 실행을 재개할 수 있는 객체
/// -> 기존 콜백, delegate 기반의 비동기 코드를 Swift Concurrency 스타일로 변환할 때 사용함
/// - CheckedContinuation, UnsafeContinuation이 존재
/// - resume 키워드를 통해 데이터를 반환하거나, 오류를 발생시킴
/// -> resume 키워드는 객체당 한번만 호출되어야 함
///
/// CheckedContinuation VS UnsafeContinuation
/// - Checked는 런타임 시 Continuation에서 오류가 있는지 검사함
/// -> resume이 호출되지 않거나, 여러번 호출된 경우 등
/// - 오류가 발생한 경우 크래쉬를 발생시킴
///
/// - Unsafe는 Checked에서 이루어지는 검사를 생략함
/// - resume 키워드를 검사하지 않기 때문에 무한정 대기 상태에 빠질 수 있음
/// - Checked 대비 Unsafe가 오버헤드가 발생시키지 않아서 속도는 조금 더 빠를 수 있음
///
/// withChecked, withUnsafe
/// - 성공 값만 반환함
/// -> 에러를 발생시키지 않음
///
/// withCheckedThrowing, withUnsafeThrowing
/// - 성공 및 에러를 반환함
///
/// Continuation 동작 방법 (checked)
/// 1. withCheckedContinuation{}가 호출되면 Continuation 객체를 생성하여 실행 컨텍스트를 캡쳐함 (await 호출 시점)
/// 2. 클로저 내부에서 Continuation 객체를 받은 후 클로저 내부 코드 실행 (비동기 요청 포함)
/// 3. 클로저 내부 코드를 전체 실행한 후 Task가 중단됨 (하단 구문 실행 X)
/// 4. 비동기 작업 완료 시 Continuation의 resume() 호출
/// 5. resume()이 호출되면 Task가 다시 스케줄링 되고, 실행이 재개됨
/// - await 전의 스레드와 이후 스레드는 다를 수 있음

func requestData(_ callBack: @escaping ((String) -> ())) {
    print("🛜 네트워크 통신 요청")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        print("✅ 네트워크 통신 완료")
        callBack("Success")
    }
}

func requestDataWithAsync() async -> String {
    print("🎬 async 함수 시작")
    
    let result = await withCheckedContinuation { continuation in
        print("💬 withCheckedContinuation 시작")
        
        requestData { data in
            print("ℹ️ 네트워크 콜백 종료")
            continuation.resume(returning: data)
        }
        
        print("💬 withCheckedContinuation 종료")
    }
    
    print("🔚 async 함수 종료")
    return result
}

Task {
    print("📜", await requestDataWithAsync())
}
