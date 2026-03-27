---
name: gemini-cli
description: |
  Google Gemini CLI 공식 문서(웹 + GitHub) 변경사항을 추적하고 상세 리포트를 생성합니다.
  웹(geminicli.com)과 GitHub(google-gemini/gemini-cli) 두 소스를 독립 추적하며,
  자가수복 크롤러로 변경을 감지하고 의미/맥락/임팩트를 분석합니다.
  Trigger: "/docs-diff:gemini-cli", "Gemini CLI docs 변경", "제미나이 문서 업데이트",
  "gemini cli docs update", "google gemini documentation changed"
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
  sources: ["geminicli.com", "github:google-gemini/gemini-cli"]
---

# docs-diff:gemini-cli — Gemini CLI Docs 변경 추적

Google Gemini CLI 공식 문서를 **웹과 GitHub 두 소스에서 독립적으로** 추적합니다.
각 소스에서 변경을 감지하고 **무엇이, 왜, 어떤 영향으로** 변경되었는지 상세 분석합니다.

## 소스

| 소스 | Type | 출처 |
|------|------|------|
| `gemini-cli/web` | web | geminicli.com/docs |
| `gemini-cli/github` | github | google-gemini/gemini-cli (Apache-2.0) |

두 소스는 **독립적으로** fetch → diff → 리포트합니다.

## 실행

1. `references/workflow.md`를 Read하여 공통 워크플로우 숙지
2. `config/sources.md`를 Read하여 Gemini CLI 소스 정보 확인
3. `data/snapshots/gemini-cli/`를 Glob으로 확인하여 초기/업데이트 모드 판별
4. **두 소스를 Agent로 병렬 fetch**:
   - Agent 1 (web): geminicli.com/docs 페이지 크롤링 → Markdown 추출
   - Agent 2 (github): `gh api repos/google-gemini/gemini-cli/contents/docs` → 파일 수집
5. 각 소스 독립적으로 Phase 2~4 실행:
   - **Phase 2 (자가수복)**: 추출 실패 시 자동 수복
   - **Phase 3 (Diff)**: `git diff -- data/snapshots/gemini-cli/` 로 변경 감지
   - **Phase 4 (리포트)**: 변경마다 What + Why + Impact 상세 분석
   - **Phase 5 (저장)**: 스냅샷 파일 업데이트 (커밋은 사용자 결정)
6. 리포트는 **단일 타겟 형식**으로 출력하되, 소스별 섹션 분리

## Gemini CLI Docs 특이사항

- Web: geminicli.com/docs, GitHub Pages(google-gemini.github.io/gemini-cli/docs/) 도 존재
- GitHub: `google-gemini/gemini-cli` 레포의 `/docs/` 디렉토리에 Markdown 파일
- 주요 추적 영역: CLI commands, MCP server, custom commands, extensions, headless mode, IDE integration
