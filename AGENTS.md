# 작업 지침

이 폴더의 `prompt-db.html` 또는 관련 파일을 수정한 뒤에는 항상 다음을 수행한다.

1. 스크립트 문법 확인
   - `prompt-db.html` 안의 `<script>` 내용을 임시 `.js` 파일로 추출한 뒤 `node --check`로 확인한다.
2. 가능하면 로컬 앱 동작을 확인한다.
   - 로컬 서버 주소: `http://127.0.0.1:8080/prompt-db.html`
3. Git 상태를 확인한다.
   - `git status`
4. 변경사항을 커밋한다.
   - `git add .`
   - `git commit -m "작업 내용 요약"`
5. GitHub에 올린다.
   - `git push`
6. 사용자에게 검증 결과와 push 결과를 간단히 보고한다.

GitHub 인증이 필요한 경우에는 사용자가 브라우저 로그인 또는 Personal Access Token 인증을 완료해야 한다.
