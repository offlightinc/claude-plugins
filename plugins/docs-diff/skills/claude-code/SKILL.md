---
name: claude-code
description: |
  Claude Code 공식 문서(docs.anthropic.com) 변경사항을 추적하고 상세 리포트를 생성합니다.
  자가수복 웹 크롤러로 docs 변경을 감지하고, 변경의 의미/맥락/임팩트를 분석합니다.
  Trigger: "/docs-diff:claude-code", "Claude Code docs 변경", "클로드 코드 문서 업데이트",
  "claude code docs update", "anthropic docs changed"
allowed-tools:
  - WebFetch
  - WebSearch
  - Read
  - Write
  - Glob
  - Bash
user-invocable: true
disable-model-invocation: true
effort: high
metadata:
  version: "0.1.0"
  author: "Team Offlight"
  sources: ["docs.anthropic.com"]
---

# docs-diff:claude-code — Claude Code Docs 변경 추적

Claude Code 공식 문서(docs.anthropic.com/en/docs/claude-code)의 변경사항을 추적합니다.
웹 크롤링으로 현재 docs를 수집하고, 이전 스냅샷과 비교하여 **무엇이, 왜, 어떤 영향으로** 변경되었는지 상세 분석합니다.

## 소스

| 소스 | Type | 출처 |
|------|------|------|
| `claude-code/web` | web | docs.anthropic.com/en/docs/claude-code |

GitHub 소스 없음 (docs 소스 비공개).

## 실행

1. `references/workflow.md`를 Read하여 공통 워크플로우 숙지
2. `config/sources.md`를 Read하여 Claude Code 소스 정보 확인
3. `data/snapshots/claude-code/web/`를 Glob으로 확인하여 초기/업데이트 모드 판별
4. 공통 워크플로우 Phase 0~5를 실행:
   - **Phase 1 (Fetch)**: docs.anthropic.com sitemap.xml에서 `/en/docs/claude-code/*` 경로 필터 → 각 페이지 WebFetch → Markdown 추출
   - **Phase 2 (자가수복)**: 추출 실패 시 raw HTML 분석 → 새 추출 전략 적용
   - **Phase 3 (Diff)**: `git diff -- data/snapshots/claude-code/` 로 변경 감지
   - **Phase 4 (리포트)**: 변경마다 What + Why + Impact 상세 분석
   - **Phase 5 (저장)**: 스냅샷 파일 업데이트 (커밋은 사용자 결정)
5. 리포트는 **단일 타겟 형식**으로 출력

## Claude Code Docs 특이사항

- Sitemap: `https://docs.anthropic.com/sitemap.xml` 에서 `claude-code` 경로만 필터
- 페이지 구조: 주로 `/en/docs/claude-code/{topic}` 패턴
- 주요 추적 영역: hooks, MCP, configuration, CLI commands, IDE integrations, permissions
