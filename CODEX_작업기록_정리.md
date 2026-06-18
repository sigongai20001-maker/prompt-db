# CODEX 작업기록 정리

작성 기준: 이 채팅에서 진행한 `프롬프트 DB` 웹앱 작업 전체  
주 작업 파일: `E:\내 드라이브\웹앱\프롬프트DB\prompt-db.html`  
배포 저장소: `https://github.com/sigongai20001-maker/prompt-db.git`  
주요 배포 URL: `https://sigongai20001-maker.github.io/prompt-db/prompt-db.html`

---

## 1부. 작업 이력: 시간순 아카이브

### 1. MD 요구사항 기반 웹앱 생성

목표: 첨부 MD의 요구대로 Google Drive JSON 기반 프롬프트 DB 웹앱을 새 작업 폴더에 구축.

진행:
- 작업 폴더를 `E:\내 드라이브\웹앱\프롬프트DB\`로 설정.
- 핵심 파일 `prompt-db.html`을 만들고 Google Drive의 `prompts.json`과 연동하는 단일 HTML 웹앱으로 구성.
- 사용자, 영역태그, 구분태그, 프롬프트 CRUD, 검색, 필터, Google 로그인 흐름을 구축.

결과:
- 최종 산출물: `E:\내 드라이브\웹앱\프롬프트DB\prompt-db.html`
- 이후 모든 기능 개선의 기준 파일이 됨.

검증:
- 로컬 서버: `http://127.0.0.1:8080/prompt-db.html`
- GitHub Pages: `https://sigongai20001-maker.github.io/prompt-db/prompt-db.html`

---

### 2. OAuth 로컬 실행 문제와 실행 파일 추가

목표: `file://`로 열면 OAuth가 실패하므로 더블클릭으로 로컬 서버를 띄우고 브라우저를 여는 실행 파일 제공.

시도:
- 사용자가 `prompt-db.html`을 더블클릭하면 `file://`로 열려 Google OAuth가 실패한다고 보고.
- 로컬 서버 주소는 `http://127.0.0.1:8080`으로 확정.

수정:
- `프롬프트DB실행.bat` 추가.
- `python -m http.server 8080` 실행.
- Python이 PATH에 없으면 `py -m http.server 8080` fallback.
- 8080 포트가 이미 사용 중이면 기존 서버를 쓰고 브라우저만 열 수 있도록 안내.
- README에 실행법 추가.

결과:
- 산출물: `E:\내 드라이브\웹앱\프롬프트DB\프롬프트DB실행.bat`
- 사용자는 더블클릭으로 로컬 서버와 앱을 열 수 있게 됨.

교훈:
- OAuth 웹앱은 `file://`가 아니라 `http://127.0.0.1:포트` 또는 HTTPS origin에서 열어야 한다.

---

### 3. Google OAuth 400 malformed / origin mismatch 수정

목표: Google 로그인 시 `400 malformed`, `origin_mismatch` 문제 해결.

증상:
- 인앱 브라우저 URL에 Google OAuth 에러가 표시됨.
- 사용자는 Google Cloud Console 승인 URI가 `http://127.0.0.1:8080`이라고 설명.

진단:
- OAuth 초기화에서 `redirect_uri`가 로컬 주소로 고정되어 있으면 GitHub Pages나 다른 origin에서 불안정해질 수 있음.
- Google Identity Services token client는 승인된 JavaScript origin 등록이 핵심.

수정:
- 로컬에서는 `http://127.0.0.1:8080` origin 기준.
- GitHub Pages에서는 Google Cloud Console에 `https://sigongai20001-maker.github.io`를 승인된 JavaScript 원본으로 등록해야 함.
- 이후 장시간 유지 작업에서 `redirect_uri` 상수와 token client 설정의 `redirect_uri`를 제거.

검증:
- `node --check` 통과.
- 로컬 앱 응답 200.
- 브라우저 오류 없음.

관련 커밋:
- `75d5950` 탭 장시간 유지 토큰 갱신 보강

---

### 4. 로그인 유지와 탭 장시간 사용 보강

목표: 탭을 오래 켜두는 앱이므로 매번 로그인하지 않고 토큰을 선제 갱신.

요청:
- 로그인 성공 시 access token과 `expires_at` 저장.
- 페이지 로드 시 유효 토큰이면 로그인 버튼 없이 Drive 연결.
- 만료 약 5분 전 `tokenClient.requestAccessToken({ prompt: "" })`로 조용히 갱신.
- 실패할 때만 로그인 버튼 표시.
- 로그아웃 시 localStorage 삭제와 타이머 해제.

시행착오:
- 토큰 저장은 정상인데 새로고침 시 자동 연결이 실행되지 않아 로그인 화면이 다시 뜸.
- 진단 결과:
  - `localStorage` 키 `prompt-db-google-token`은 정상.
  - `expires_at`도 유효.
  - 문제는 초기화 시 저장 토큰을 읽어 Drive 연결하는 로직이 호출되지 않던 것.

수정:
- `tryAutoConnectFromStoredToken()`을 초기화 흐름에서 실제 호출.
- `readStoredToken()`, `restoreStoredToken()`, `scheduleTokenRefresh()` 정리.
- `visibilitychange`, `focus` 이벤트 추가.
- 탭이 절전/백그라운드에서 돌아왔을 때 토큰 만료 임박이면 조용히 갱신.
- `tokenRefreshInFlight`로 중복 갱신 방지.
- GitHub Pages에서 불필요한 `redirect_uri` 제거.

결과:
- 탭을 오래 켜도 만료 전 자동 갱신.
- 브라우저가 타이머를 지연해도 포커스 복귀 시 재점검.

검증:
- `node --check` 통과.
- 로컬 응답 200.
- 브라우저 콘솔 오류 없음.

관련 커밋:
- `75d5950` 탭 장시간 유지 토큰 갱신 보강

---

### 5. Git/GitHub 연결과 자동 업로드 배치

목표: 로컬 Google Drive 폴더를 GitHub 저장소와 연결하고, 수정 후 push하면 GitHub Pages에 반영되게 구성.

진행:
- 작업 폴더에서 `git init`.
- 브랜치 `main`.
- 원격 `origin`: `https://github.com/sigongai20001-maker/prompt-db.git`
- 원격 main과 동기화.
- `GitHub업로드.bat` 생성: 변경사항을 날짜/시간 커밋 메시지로 자동 커밋/push.

시행착오:
- 사용자가 PowerShell `C:\WINDOWS\system32`에서 `git add .; git commit; git push`를 실행해 `not a git repository` 오류 발생.
- 해결:
  - 먼저 `cd "E:\내 드라이브\웹앱\프롬프트DB"`로 이동해야 함.
- 이후 정상 push 확인.

검증:
- `git status`
- `git remote -v`
- 실제 push 성공 로그 확인.

산출물:
- `E:\내 드라이브\웹앱\프롬프트DB\GitHub업로드.bat`
- `E:\내 드라이브\웹앱\프롬프트DB\AGENTS.md`

교훈:
- Git 명령은 반드시 저장소 폴더에서 실행.
- Google Drive 동기화 폴더에서도 사용 가능하지만, 동기화 중 충돌에는 주의.

---

### 6. 작업 지침 파일 생성

목표: 앞으로 “수정 후 GitHub까지 올리기”를 매번 잊지 않도록 프로젝트 지침 파일 생성.

수정:
- `AGENTS.md` 작성.
- 지침:
  - `prompt-db.html` 또는 관련 파일 수정 후 `node --check`.
  - 로컬 앱 확인.
  - `git status`.
  - 커밋.
  - push.
  - 사용자에게 검증 결과와 push 결과 보고.

결과:
- 이후 대부분의 작업에서 문법 확인, 로컬 응답 확인, 브라우저 확인, push를 수행.

산출물:
- `E:\내 드라이브\웹앱\프롬프트DB\AGENTS.md`

---

### 7. 프롬프트 목록 UI: 카드형에서 가로 긴 리스트형으로 변경

목표: 프롬프트를 카드가 아니라 가로로 긴 버튼/리스트 형태로 한 줄씩 세로 배치.

진행:
- 기존 카드형 UI가 한 화면에 카드처럼 보이던 구조.
- 사용자가 “가로로 긴 버튼으로 한줄씩 세로배치” 요청.

수정:
- 프롬프트 항목을 리스트형 행으로 변경.
- 제목, 사용자, 태그, 내용 미리보기, 편집 버튼을 한 줄 안에 배치.
- 제목 영역은 화면 비율과 관계없이 한 줄로 보이게 `nowrap`, 말줄임 처리.

검증:
- 화면 캡처상 프롬프트가 긴 가로 행으로 표시됨.
- GitHub push 완료.

관련 커밋:
- `c6e2e39` Keep prompt title on one line
- 이후 리스트형 UI 관련 커밋들

교훈:
- UI 방식 변경은 데이터 로직과 분리해서 좁게 적용해야 안정적.

---

### 8. 사용자/영역태그/구분태그 추가와 관리

목표:
- 사용자 추가 버튼.
- 영역태그 추가 버튼.
- 영역태그 안에 구분태그 추가.
- 구분태그 멀티태그 지원.
- 이름변경/삭제 가능.

진행:
- 사용자, 영역태그, 구분태그 추가 버튼을 별도 배치.
- 구분태그는 영역태그 하위 필터로 표시.
- 프롬프트 등록 시 체크박스 형태로 멀티 구분태그 선택 가능.

시행착오 1: 관리 UX 혼란
- 처음에는 `관리` 버튼 하나로 `prompt()`를 띄워 기존 항목을 선택하고 다시 이름변경/삭제를 처리.
- 사용자가 `CODEX -> 웹앱개발`로 바꾸려 했지만, 첫 prompt가 “기존 항목 선택”이라 새 이름을 입력해도 아무 변화 없음.
- 해결:
  - 선택된 항목이 있으면 바로 이름변경 대상으로 처리.
  - 이후 `관리` 단일 버튼을 없애고, 선택된 태그 아래에 `이름변경` / `삭제` 버튼을 직접 표시.

시행착오 2: CODEX 삭제 불가
- 기존 보호 로직 때문에 `CODEX 영역태그는 삭제할 수 없습니다` 표시.
- 사용자는 기본 태그도 삭제 가능해야 한다고 피드백.
- 해결:
  - 기본 영역태그 삭제 허용.
  - 삭제한 기본 영역태그가 새로고침 때 다시 살아나지 않도록 `deletedCategories` 도입.

검증:
- `node --check`.
- 로컬 응답 200.
- 브라우저 오류 없음.
- GitHub push 완료.

관련 커밋:
- `074ca5e` Add tag rename and delete management
- `08dad32` 태그 관리 이름변경 흐름 개선
- `ef7355c` 태그 관리 버튼 분리
- `ca47c0b` 기본 영역태그 삭제 허용

---

### 9. 영역태그 이름변경/삭제와 `deletedCategories` 충돌 해결

목표: `CODEX -> 웹앱개발`, 다시 `웹앱개발 -> CODEX` 같은 변경에서 태그가 사라지거나 꼬이지 않게 함.

문제 1:
- `CODEX`를 `웹앱개발`로 이름변경 후 프롬프트 일부가 여전히 `CODEX` 배지를 표시.
- 탭에는 `웹앱개발`이 있는데 카드 배지는 `CODEX`로 남아 있음.

진단:
- `CODEX`가 기본 영역태그라 자동 복원되는 구조.
- 동시에 `deletedCategories`에 `CODEX`가 들어가면 숨김 처리됨.
- 실제 프롬프트의 `category` 값과 태그 목록이 어긋남.

수정:
- `repairHiddenPromptCategories()` 추가.
- 로드 시 숨겨진 영역태그를 쓰는 프롬프트를 보이는 영역태그로 자동 이동.
- `CODEX`가 숨겨져 있고 `웹앱개발`이 있으면 `CODEX` 프롬프트를 `웹앱개발`로 이동.

문제 2:
- `웹앱개발`을 다시 `CODEX`로 이름변경하면 `CODEX`가 `deletedCategories`에 남아 있어 다시 숨김 처리.

진단:
- 이름변경은 “그 이름을 다시 살리겠다”는 의도인데, 삭제목록에서 새 이름을 빼지 않았음.
- Drive 최신 데이터와 병합할 때 이전 `deletedCategories`가 다시 합쳐져 되살린 이름이 또 삭제목록에 들어갈 수 있음.

수정:
- `reviveDeletedCategoryName(value)` 추가.
- 이름변경 시 새 이름이 `deletedCategories`에 있으면 제거.
- 로드 시 실제 프롬프트가 쓰는 영역태그가 `deletedCategories`에 있으면 삭제목록에서 제거.
- 병합 과정에서 방금 되살린 이름이 다시 삭제목록에 합쳐지지 않게 필터.

관련 커밋:
- `59a5ac2` 영역태그 이름변경 데이터 복구
- `6330955` 영역태그 삭제목록 복구

교훈:
- 삭제목록을 따로 두면 “삭제”와 “이름 재사용”의 의미를 분리해야 한다.
- 이름변경은 새 이름을 삭제목록에서 제거하는 작업까지 포함해야 한다.

---

### 10. 구분태그 삭제 후 부활 문제 해결

목표: 구분태그 `CODEX`를 삭제해도 다시 나타나는 문제 해결.

문제:
- 사용자가 구분태그 `CODEX` 선택 후 삭제를 눌렀으나 다시 나타남.

진단:
- `deleteActiveSubTag()`가 `state.tagGroups[category]`에서는 제거했지만, 각 `prompt.tags` 안에 `CODEX`가 남아 있었음.
- `normalizeTagGroups()`가 프롬프트들의 `tags`를 다시 모아 `tagGroups`를 만들기 때문에 부활.
- Drive 최신 데이터와 병합할 때 옛 tags가 다시 섞일 수 있음.

수정:
- `deleteActiveSubTag()`에서 해당 category의 모든 `prompt.tags`에서도 태그 제거.
- `persistChange()`에 `deletedSubTags` 옵션 추가.
- Drive 최신 데이터 병합 전에 `removeDeletedSubTagsFromPrompts()`로 latest prompts에서도 제거.
- `removeDeletedSubTagsFromTagGroups()`로 최신 tagGroups와 최종 병합 결과에서도 제거.
- 이후 사용자별 계층 도입 시 `removeDeletedSubTagsFromOwnerTagGroups()`까지 추가.

관련 커밋:
- `e3e7ee1` 구분태그 삭제 부활 방지

교훈:
- 파생 목록을 삭제하려면 원천 데이터도 함께 삭제해야 한다.
- 이 앱에서 구분태그의 원천은 `tagGroups`만이 아니라 `prompts[].tags`다.

---

### 11. 사용성: 사용빈도순 정렬

목표: 많이 사용하는 프롬프트가 위에 오도록 정렬.

수정:
- 복사 시 `usageCount`, `lastUsedAt` 갱신.
- 목록 정렬:
  1. `usageCount` 높은 순
  2. `lastUsedAt` 최신 순
  3. `createdAt` 최신 순

검증:
- 복사 후 사용 횟수 저장.
- 목록 상단 노출.

관련 커밋:
- `b6a56b9` Sort prompts by usage count

교훈:
- “사용성” 요구는 화면 배치뿐 아니라 데이터 기록 필드가 필요하다.

---

### 12. 등록 과정 인지 UI 개선

목표: 사용자가 데이터 등록 시 현재 과정이 보이게 함.

1차 수정:
- 저장 버튼 클릭 시 버튼이 `저장 중`으로 바뀌고 spinner 표시.
- 모달 하단에 `입력 확인 중`, `Drive에 저장 중`, `등록 완료`, `저장 실패` 표시.

문제:
- 사용자는 “저장중 UI 알림은 팝업창 말고 메인 화면 하단에 작게 표시”를 원함.
- 저장 중에도 계속 등록/작업해야 함.
- 기존 방식은 팝업 안에 `Drive에 저장 중`이 떠서 작업을 막는 느낌.

2차 수정:
- `syncToast` 추가.
- 메인 화면 하단 왼쪽에 작고 별도인 저장 상태 표시.
- 새 프롬프트 등록은 화면에 즉시 반영.
- Drive 저장은 `queueBackgroundSave()`로 백그라운드 큐 처리.

3차 수정:
- 사용자/영역태그/구분태그 추가도 팝업 즉시 닫힘으로 변경.
- 이후 기존 프롬프트 수정도 저장 버튼 누르는 즉시 팝업 닫힘으로 변경.
- 저장 상태는 팝업 내부가 아니라 메인 하단 `syncToast`에만 표시.

관련 커밋:
- `43a175b` 등록 진행 상태 UI 개선
- `84f2539` 프롬프트 등록 백그라운드 저장
- `8b862cc` 등록 팝업 즉시 닫기
- `ccb0a57` 수정 저장 팝업 즉시 닫기

교훈:
- “저장 중 표시”와 “작업 차단”은 다르다.
- 사용자가 연속 입력을 원하면 optimistic UI + background sync가 맞다.

---

### 13. 활성 태그 자동 적용

목표: 데이터 등록 시 활성화된 사용자/영역/구분태그를 자동으로 붙여 등록.

1차 수정:
- 새 프롬프트 모달을 열 때 현재 활성 영역태그와 구분태그를 기본값으로 넣음.
- 기존 프롬프트 수정 시에는 저장된 태그 유지.

문제:
- 등록창 안에서 사용자가 값 변경 가능.
- “무조건 활성화된 태그를 붙인다”는 원칙이 저장 시점에는 보장되지 않음.

수정:
- `getForcedNewPromptContext()` 추가.
- 새 프롬프트 저장 시:
  - `owner = getDefaultNewOwner()`
  - `category = getDefaultNewCategory()`
  - `tags = getDefaultNewPromptTags(category)`
- 새 프롬프트는 등록창 안의 사용자/영역/구분 입력값보다 활성 태그가 우선.
- 기존 프롬프트 수정은 수정창 값 기준 유지.

관련 커밋:
- `1a156b4` 활성 태그 자동 등록
- `f396de5` 새 프롬프트 활성 태그 강제 적용

교훈:
- 기본값 설정과 저장 시점 강제는 다르다.
- “무조건” 요구는 저장 함수에서 보장해야 한다.

---

### 14. 사용자별 태그 계층 분리

목표: 사용자 태그에 따라 하위 영역태그와 구분태그를 분리.

요구 해석:

```text
사용자
 └─ 영역태그
     └─ 구분태그
```

수정:
- `ownerTagGroups` 필드 추가.
- 기존 전역 `tagGroups`는 유지하되, 사용자별 하위 구조를 `ownerTagGroups`로 저장.
- 기존 프롬프트 데이터를 기준으로 자동 이관.
- 사용자 탭 변경 시:
  - `activeCategory = "전체"`
  - `activeSubTag = "전체"`
  - 영역/구분태그 목록 재렌더링.
- `getCategories(owner = state.activeOwner)`가 활성 사용자 기준으로 영역태그 반환.
- `getTagsForCategory(category, owner = state.activeOwner)`가 활성 사용자와 영역 기준으로 구분태그 반환.
- 새 영역/구분태그 추가 시 현재 사용자 아래에 기록.
- 프롬프트 등록/수정 시 해당 사용자 아래의 태그 계층 갱신.
- 사용자 범위에서 영역/구분태그 이름변경/삭제가 동작하도록 보정.

시행착오 회피:
- 기존 `normalizeTagGroups()`는 기본 `CODEX` 태그를 자동 삽입하므로 사용자별 태그에 그대로 쓰면 모든 사용자에게 CODEX가 섞일 수 있음.
- 해결:
  - `normalizeTagGroups(..., includeDefaults = false)` 옵션 추가.
  - 사용자별 태그그룹 정규화에서는 기본값 자동 주입 금지.

관련 커밋:
- `80d6eac` 사용자별 태그 계층 분리

교훈:
- 전역 태그와 사용자별 태그는 동시에 유지하되 조회 경로를 분리해야 기존 데이터가 안전하다.
- 데이터 구조를 바꿀 때는 자동 이관 함수를 먼저 둬야 한다.

---

### 15. 원격 변경 충돌/리베이스 처리

문제:
- push 중 원격에 다른 변경이 먼저 올라와 `fetch first` 거절 발생.

상황:
- 로컬: `등록 팝업 즉시 닫기` 커밋 1개 ahead.
- 원격: 다른 작업 17개 behind 상태.

해결:
- `git fetch origin`
- `git rebase origin/main`
- 충돌 없이 리베이스 성공.
- `node --check`, 로컬 응답 확인 후 push.

관련 기록:
- 로컬 커밋 `1f963e6`이 리베이스 후 `8b862cc`로 재작성됨.

교훈:
- push 거절 시 강제 push 금지.
- 먼저 fetch/rebase로 원격 변경을 보존하고, 내 변경을 그 위에 얹는다.

---

## 2부. 재사용 교훈: 다음 작업용 플레이북

### A. 처음부터 적용할 규칙

1. 작업 시작 전 상태 확인
   - `git status --short --branch`
   - `git fetch origin`
   - 필요 시 `git pull --ff-only`

2. 수정 전 DOM/함수 위치 먼저 확인
   - `rg -n "관련 함수명|버튼 id|상태값" prompt-db.html`
   - 주변 코드 `Get-Content -Encoding UTF8 ... | Select-Object -Skip ...`

3. 기능 수정은 저장 경로와 표시 경로를 분리해서 생각
   - 화면 표시: `renderTabs`, `renderCodexFilters`, `renderPrompts`
   - 저장 payload: `createDatabasePayload`
   - Drive 병합: `persistChange`, `syncDriveChanges`
   - 정규화: `normalizePrompts`, `normalizeTagGroups`, `normalizeOwnerTagGroups`

4. 변경 후 반드시 확인
   - HTML script 추출 후 `node --check`
   - 로컬 응답 200
   - 브라우저 콘솔 오류 없음
   - `git diff --stat`
   - 커밋
   - push

5. GitHub Pages/OAuth 관련
   - `redirect_uri`를 임의로 고정하지 않는다.
   - Google Cloud Console 승인 JavaScript origin에 `https://sigongai20001-maker.github.io` 필요.
   - 장시간 탭 유지에는 `expires_at`, silent refresh, focus/visibility 재점검이 필요.

---

### B. 이번에 막혔던 지점과 결정적 해결책

1. 자동 로그인 실패
   - 막힘: 토큰은 저장됐지만 로드 시 로그인 화면.
   - 해결: `tryAutoConnectFromStoredToken()`을 초기화 경로에서 실제 호출.

2. CODEX 이름변경/삭제 꼬임
   - 막힘: 기본 태그 자동 복원 + `deletedCategories`가 충돌.
   - 해결:
     - 이름 재사용 시 `deletedCategories`에서 제거.
     - 실제 프롬프트가 쓰는 영역태그는 로드 시 삭제목록에서 복구.

3. 구분태그 삭제 후 부활
   - 막힘: `tagGroups`만 지우고 `prompts[].tags`를 지우지 않음.
   - 해결:
     - 원천인 `prompts[].tags`에서 제거.
     - Drive 병합 전 latestData에서도 제거.

4. 저장 중 UI가 작업을 막음
   - 막힘: 팝업 내부 `Drive에 저장 중` 때문에 창이 안 닫히는 느낌.
   - 해결:
     - `syncToast`를 메인 하단에 별도 표시.
     - 등록/수정은 optimistic UI로 즉시 반영.
     - Drive 저장은 `queueBackgroundSave()`로 백그라운드 처리.

5. 활성 태그 자동 등록이 불완전
   - 막힘: 모달 기본값은 맞지만 저장 시 바뀔 수 있음.
   - 해결:
     - `getForcedNewPromptContext()`로 저장 시점에 강제.

6. 사용자별 태그 분리
   - 막힘: 기존 전역 태그 구조에서는 사용자 변경 후에도 영역/구분태그가 섞임.
   - 해결:
     - `ownerTagGroups` 도입.
     - 조회 함수 `getCategories(owner)`, `getTagsForCategory(category, owner)`를 활성 사용자 기준으로 변경.

---

### C. 다음 작업 체크리스트

#### 기능 추가 전

- [ ] 이 기능이 화면 상태만 바꾸는가, Drive JSON 구조도 바꾸는가?
- [ ] 기존 `prompts.json` 마이그레이션이 필요한가?
- [ ] 새 필드를 추가하면 `createDefaultDatabase()`와 `createDatabasePayload()`에 모두 넣었는가?
- [ ] 로드 시 기존 데이터에 필드가 없을 때 보정하는가?
- [ ] Drive 최신 데이터와 병합할 때 새 필드가 유지되는가?

#### 태그/필터 작업

- [ ] 전역 태그인지 사용자별 태그인지 먼저 결정.
- [ ] `state.categories`, `state.tagGroups`, `state.ownerTagGroups`, `state.prompts[].tags` 중 원천이 무엇인지 확인.
- [ ] 삭제 작업이면 파생 목록뿐 아니라 원천 데이터도 지웠는가?
- [ ] 이름변경이면 삭제목록에서 새 이름을 살렸는가?
- [ ] 활성 사용자 변경 시 영역/구분태그를 초기화하는가?

#### 저장/동기화 작업

- [ ] 사용자가 기다려야 하는 저장인가, 백그라운드 저장인가?
- [ ] 백그라운드 저장이면 팝업 내부 진행문구를 띄우지 않는가?
- [ ] 저장 실패 시 사용자에게 메인 화면 하단 알림이 남는가?
- [ ] optimistic UI 후 Drive 실패 시 복구가 필요한 작업인가?
- [ ] `queueBackgroundSave()` 순서 보장이 필요한가?

#### OAuth/로그인 작업

- [ ] localStorage token 키: `prompt-db-google-token`
- [ ] `access_token`, `expires_at`, 가능하면 `issued_at` 저장.
- [ ] 페이지 로드 시 유효 토큰이면 바로 Drive 연결.
- [ ] 만료 전 `prompt: ""` silent refresh.
- [ ] `visibilitychange`/`focus`에서 재점검.
- [ ] GitHub Pages origin 등록 확인.

#### 검증

- [ ] `node --check` 통과.
- [ ] `Invoke-WebRequest http://127.0.0.1:8080/prompt-db.html` 200.
- [ ] 브라우저 로드 후 console error 없음.
- [ ] `git status --short --branch` 확인.
- [ ] 커밋 메시지가 작업 의미를 드러내는가?
- [ ] `git push` 완료.

---

### D. CODEX에 넘길 때 빠뜨리면 안 되는 전제

- “다른 로직은 건드리지 마”가 있으면 관련 함수만 좁게 수정.
- `prompt-db.html` 수정 후 반드시 `node --check`.
- UI 변경 후 가능하면 브라우저 로드와 콘솔 오류 확인.
- 저장/Drive 동기화 변경은 `persistChange`, `syncDriveChanges`, `createDatabasePayload`까지 같이 확인.
- 태그 삭제/이름변경은 `prompts` 원천 데이터까지 확인.
- GitHub까지 올려야 하는 프로젝트이므로 커밋/push까지 수행.
- push 거절 시 강제 push 금지. `fetch` → `rebase` → 검증 → push.

---

### E. 피해야 할 안티패턴

1. prompt로 관리 항목 선택 후 다시 이름변경 입력
   - 사용자가 새 이름을 첫 prompt에 입력해도 무시되는 UX가 발생.
   - 해결된 방식: 선택된 항목 아래 `이름변경` / `삭제` 버튼 직접 제공.

2. 기본 태그를 하드코딩 보호
   - `CODEX 삭제 불가`처럼 사용자의 실제 관리 의도와 충돌.
   - 기본 태그도 삭제/이름변경 가능하게 하고, 삭제목록/복구 규칙으로 관리.

3. 파생 목록만 삭제
   - `tagGroups`만 지우면 `prompts[].tags`에서 다시 부활.
   - 원천 데이터까지 수정해야 함.

4. 저장 중 팝업 잠금
   - 연속 입력 업무에서는 방해.
   - 하단 작은 저장 알림 + background sync가 맞음.

5. 기본값만 자동 적용
   - 사용자가 입력창에서 바꾸면 원칙이 깨짐.
   - “무조건” 요구는 저장 시점에 강제.

6. 원격 변경 무시하고 push
   - push reject 발생.
   - 강제 push 대신 rebase.

7. 사용자별 태그 구조에서 기본 태그 자동 주입
   - 모든 사용자에게 `CODEX`가 섞임.
   - 사용자별 정규화에서는 `includeDefaults = false`.

---

## 미해결/미확인 항목

- 실제 GitHub Pages에서 Google OAuth silent refresh가 장시간 탭 유지 상황에서 몇 시간 이상 안정 동작하는지는 장기 관찰 필요.
- 백그라운드 저장 실패 시 optimistic UI를 자동 rollback할지, 현재처럼 하단 오류 알림만 둘지는 정책 미확정.
- `ownerTagGroups` 도입 후 기존 Drive JSON 데이터가 모든 계정/PC에서 기대대로 자동 이관되는지 장기 사용 확인 필요.
- 원격에 `image-part-editor.html` 관련 커밋들이 다수 추가되었으나, 이 문서는 `prompt-db.html` 중심 작업만 정리했다.

---

## 최종 산출물 요약

- 메인 앱: `E:\내 드라이브\웹앱\프롬프트DB\prompt-db.html`
- 로컬 실행: `E:\내 드라이브\웹앱\프롬프트DB\프롬프트DB실행.bat`
- GitHub 업로드: `E:\내 드라이브\웹앱\프롬프트DB\GitHub업로드.bat`
- 작업 지침: `E:\내 드라이브\웹앱\프롬프트DB\AGENTS.md`
- 본 문서: `E:\내 드라이브\웹앱\프롬프트DB\CODEX_작업기록_정리.md`

