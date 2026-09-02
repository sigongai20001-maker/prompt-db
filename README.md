# 프롬프트 DB

Google Drive의 `prompts.json`과 동기화되는 로컬 단일 HTML 웹앱입니다.

## 도면검토 정적판

`drawing-review.html`이 도면검토 도구의 정식 버전입니다. 서버 없이 Chrome 또는 Edge에서 실행됩니다. 기본 사용은 제출건 폴더를 만들지 않는 **PDF 빠른 검토**이며, 기존 `comments.json` 프로젝트를 이어갈 때만 폴더 열기를 사용합니다.

### 기본 4단계

1. 원본 PDF를 화면에 놓거나 클릭해 첨부합니다.
2. PDF를 페이지별로 넘겨 보며 확대·축소합니다.
3. 사각형·원·다점 폴리곤·자유연필로 수정 부위를 표시하고, 각 표시와 연결된 텍스트 상자에 내용을 입력합니다. 텍스트 상자는 별도로 이동하고 다시 편집할 수 있습니다.
4. 코멘트 상태와 중문 검수를 완료한 뒤 한글 PDF와 중문 PDF를 각각 다운로드합니다.

빠른 검토의 내부 데이터는 사이트가 브라우저 전용 저장소에 자동 관리하므로 `00_수신원본` 등 7개 폴더가 화면에 나타나지 않습니다. 같은 PDF를 같은 PC·브라우저 프로필에서 다시 선택하면 코멘트가 복원됩니다. 사이트 데이터 삭제나 다른 PC·프로필에서는 복원되지 않으므로 중요한 결과는 PDF로 다운로드해 보관합니다.

- 공개 URL: https://sigongai20001-maker.github.io/prompt-db/drawing-review.html
- 지원 브라우저: 최신 Chrome 또는 Edge
- 기본 입력: PDF 클릭 선택 또는 드래그 앤 드롭
- 기존 프로젝트: 브라우저 폴더 선택 다이얼로그와 최근 작업 목록 사용
- 데이터 저장: 기존 `_review/comments.json` 포맷과 회전 전 좌표 `rect: [x0,y0,x1,y1]` 유지
- 번역 API 키: 선택 폴더·저장소·로그에 기록하지 않고 현재 브라우저 탭 메모리에만 보관
- 라이브러리: PDF.js 3.11.174, pdf-lib 1.17.1, ExcelJS 4.4.0 CDN

기존 `G:\내 드라이브\웹앱\도면 검토` Flask 앱은 검증 근거와 비교를 위한 참조용으로만 남깁니다. 새 실사용은 위 정적 버전을 기준으로 합니다.

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
- `drawing-review.html`: 도면검토 정식 정적 웹앱
- `prompts.json`: Google Drive 폴더 안에 자동 생성되는 DB 파일

## 참고

Google OAuth는 `file://`보다 `http://localhost` 접근이 안정적입니다.
