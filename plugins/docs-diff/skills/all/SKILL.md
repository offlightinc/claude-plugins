---
name: all
description: |
  AI 코딩 도구 3종(Claude Code, OpenAI Codex, Gemini CLI)의 공식 문서 변경사항을
  한번에 추적하고 통합 리포트를 생성합니다. 크로스 레퍼런스(제품 간 비교 분석) 포함.
  Trigger: "/docs-diff:all", "/docs-diff", "전체 docs 변경", "문서 전체 업데이트 체크",
  "all docs update", "check all documentation changes"
allowed-tools:
  - WebFetch
  - WebSearch
  - Read
  - Write
  - Glob
  - Bash
  - Agent
user-invocable: true
disable-model-invocation: true
effort: high
metadata:
  version: "0.1.0"
  author: "Team Offlight"
  sources: ["docs.anthropic.com", "developers.openai.com", "geminicli.com", "github:openai/codex", "github:google-gemini/gemini-cli"]
---

# docs-diff:all — 전체 AI Coding Tool Docs 변경 추적

Claude Code, OpenAI Codex, Gemini CLI 3개 타겟의 문서를 한번에 추적하고,
통합 리포트 + **크로스 레퍼런스**(제품 간 비교 분석)를 생성합니다.

## 소스 (총 5개)

| 소스 | 타겟 | Type | 출처 |
|------|------|------|------|
| `claude-code/web` | Claude Code | web | docs.anthropic.com/en/docs/claude-code |
| `codex/web` | Codex | web | developers.openai.com/codex |
| `codex/github` | Codex | github | openai/codex |
| `gemini-cli/web` | Gemini CLI | web | geminicli.com/docs |
| `gemini-cli/github` | Gemini CLI | github | google-gemini/gemini-cli |

## 실행

1. `references/workflow.md`를 Read하여 공통 워크플로우 숙지
2. `config/sources.md`를 Read하여 전체 소스 정보 확인
3. **3개 타겟을 Agent로 병렬 실행**:
   - Agent 1: Claude Code — docs.anthropic.com 웹 크롤링 (1개 소스)
   - Agent 2: OpenAI Codex — developers.openai.com 크롤링 + openai/codex GitHub fetch (2개 소스)
   - Agent 3: Gemini CLI — geminicli.com 크롤링 + google-gemini/gemini-cli GitHub fetch (2개 소스)
   - 각 Agent는 `references/workflow.md`를 Read한 뒤 Phase 0~3을 독립 실행
4. 모든 Agent 완료 후 **통합 리포트 생성** (Phase 4):
   - 각 타겟별 변경사항 취합
   - **전체 형식**으로 출력 (workflow.md의 "전체 - all" 형식 참조)
   - **크로스 레퍼런스** 섹션 추가
5. Phase 5: 스냅샷 저장 (각 Agent에서 이미 완료)

## 크로스 레퍼런스 기준

다음 경우에 크로스 레퍼런스를 생성:
- 같은 기능/개념이 여러 제품에서 변경됨
- 한 제품에 추가된 기능이 다른 제품에는 이미 있음 (또는 없음)
- 업계 전체 트렌드가 보이는 변경 (예: 보안 강화, 에이전트 자율성 확대 등)
- 예: "Codex와 Gemini CLI 모두 MCP 지원을 추가 — Claude Code는 이미 지원 중"
- 예: "세 제품 모두 샌드박스 강화 방향으로 이동 중"
