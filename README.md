# 프롬프트 DB

Google Drive의 `prompts.json`과 동기화되는 로컬 단일 HTML 웹앱입니다.

## 실행

더블클릭으로 실행하려면 `프롬프트DB실행.bat`을 실행합니다.

작업 폴더로 이동합니다.

```powershell
cd "E:\내 드라이브\웹앱\프롬프트DB"
```

간단한 로컬 서버를 실행합니다.

```powershell
python -m http.server 8080
```

브라우저에서 아래 주소를 엽니다.

```text
http://localhost:8080/prompt-db.html
```

Node.js를 선호하면 아래 명령도 사용할 수 있습니다.

```powershell
npx serve .
```

## 파일

- `prompt-db.html`: 앱 본문 전체가 들어 있는 단일 HTML 파일
- `prompts.json`: Google Drive 폴더 안에 자동 생성되는 DB 파일

## 참고

Google OAuth는 `file://`보다 `http://localhost` 접근이 안정적입니다.
