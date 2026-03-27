# 리포트 예시

실제 실행 시 출력되는 리포트의 예시입니다. 스킬이 이 형식을 참조하여 리포트를 생성합니다.

---

## 단일 타겟 예시 (/docs-diff:claude-code)

```markdown
# Claude Code Docs 변경 리포트 — 2026-03-27

## 요약
- 1개 소스(web)에서 변경 2건 감지
- 주요 변경: Hook 환경변수 접근 지원, 새 permission 모드 추가

---

## [claude-code/web]

### ✦ hooks.md — Hook에서 환경변수 직접 접근 가능

**무엇이 바뀌었는가:**
Pre-tool-use hook과 Post-tool-use hook에서 `CLAUDE_*` 접두사가 붙은
환경변수에 접근할 수 있게 되었다. 이전에는 hook 스크립트가 실행될 때
Claude Code의 환경변수를 상속받지 못했다.

새로 접근 가능한 환경변수:
- `CLAUDE_PROJECT_DIR` — 현재 프로젝트 경로
- `CLAUDE_MODEL` — 실행 중인 모델명
- `CLAUDE_SESSION_ID` — 현재 세션 ID

**왜 중요한가:**
이전에는 hook에서 프로젝트 경로나 모델 정보를 알 수 없어서
임시 파일에 경로를 저장하는 등의 workaround가 필요했다.
이번 변경은 hook 기반 자동화의 진입 장벽을 크게 낮추는 방향이며,
Codex와 Gemini CLI가 이미 유사한 기능을 제공하고 있었던 점에서
경쟁 대응 의미도 있다.

**실제 영향:**
- hook에서 `$CLAUDE_PROJECT_DIR`, `$CLAUDE_MODEL` 등을 직접 참조 가능
- 기존 workaround (임시 파일, 환경변수 수동 설정) 제거 가능
- 모델별/프로젝트별 다른 동작을 하는 hook 패턴이 가능해짐

### ✦ permissions.md — 새 "auto" permission 모드 추가

**무엇이 바뀌었는가:**
기존 permission 모드(default, acceptEdits, bypassPermissions) 외에
`auto` 모드가 추가되었다. auto 모드에서는 Claude가 도구 사용 위험도를
자체 판단하여 저위험 작업은 자동 승인, 고위험 작업만 사용자 확인을 요청한다.

**왜 중요한가:**
기존에는 "모든 것 물어보기(default)"와 "아무것도 안 물어보기(bypass)" 사이에
중간 선택지가 없었다. auto 모드는 이 간극을 메우며,
일상적인 코딩 작업에서 승인 피로(approval fatigue)를 줄이면서도
위험한 작업에 대한 안전장치를 유지한다.

**실제 영향:**
- `claude --permission auto`로 실행 가능
- Read, Glob, Grep 등은 자동 승인
- Write, Bash(rm 등), git push 등은 여전히 확인 필요
- 기존 permission 설정과 병행 사용 가능

---

## 크롤러 상태
| 소스 | 상태 | 비고 |
|------|------|------|
| claude-code/web | ✅ 정상 | 25 페이지 수집 |
```

---

## 전체 타겟 예시 (/docs-diff:all) — 크로스 레퍼런스 부분

```markdown
## 크로스 레퍼런스

### MCP 서버 지원 확대 — 3개 제품 동시 움직임

이번 체크에서 3개 제품 모두 MCP 관련 docs가 업데이트되었다:
- **Claude Code**: MCP 서버 설정에 `allowedOrigins` 보안 옵션 추가
- **Codex**: MCP 서버 연동 가이드 신규 페이지 추가
- **Gemini CLI**: MCP 프로토콜 v2 지원 명시

이는 AI 코딩 도구 시장에서 MCP가 사실상 표준 확장 프로토콜로
자리잡고 있음을 보여준다. 특히 Codex가 MCP 가이드를 새로 추가한 것은
OpenAI가 이 생태계에 본격적으로 참여하겠다는 신호.

### 샌드박스 강화 — Codex와 Gemini CLI

- **Codex**: `--sandbox strict` 모드 추가, 네트워크 격리 강화
- **Gemini CLI**: 파일시스템 접근 제한 옵션 세분화

Claude Code는 이미 permission 모드로 유사 기능을 제공 중이지만,
"샌드박스"라는 단일 개념으로 묶지 않고 개별 permission으로 관리하는 방식.
접근법은 다르지만 방향은 동일: 에이전트 자율성과 안전성의 균형.
```
