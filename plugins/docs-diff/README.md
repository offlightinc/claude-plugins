# docs-diff

AI 코딩 도구 3종의 공식 문서 변경사항을 추적하고 상세 리포트를 생성하는 Claude Code 플러그인.

## 추적 대상

| 대상 | 웹 소스 | GitHub 소스 |
|------|---------|-------------|
| **Claude Code** | docs.anthropic.com | - |
| **OpenAI Codex** | developers.openai.com | openai/codex |
| **Gemini CLI** | geminicli.com | google-gemini/gemini-cli |

## 스킬

| 스킬 | 호출 | 설명 |
|------|------|------|
| `claude-code` | `/docs-diff:claude-code` | Claude Code docs만 추적 |
| `codex` | `/docs-diff:codex` | OpenAI Codex docs만 추적 |
| `gemini-cli` | `/docs-diff:gemini-cli` | Gemini CLI docs만 추적 |
| `all` | `/docs-diff:all` | 전체 추적 + 크로스 레퍼런스 |

## 핵심 기능

- **자가수복 크롤러**: 사이트 구조가 변경되면 자동으로 새 추출 전략 적용
- **상세 변경 분석**: 단순 diff가 아닌 What(사실) + Why(맥락) + Impact(영향) 분석
- **크로스 레퍼런스**: 전체 추적 시 제품 간 유사 변경/트렌드 비교 분석
- **독립 소스 추적**: 웹과 GitHub를 독립적으로 추적하여 누락 없이 변경 감지

## 사용법

```bash
# 설치
claude plugin install docs-diff@team-offlight

# 실행
/docs-diff:all              # 전체 추적
/docs-diff:claude-code      # Claude Code만
/docs-diff:codex            # OpenAI Codex만
/docs-diff:gemini-cli       # Gemini CLI만
```

## 구조

```
docs-diff/
├── skills/                  # 4개 스킬
│   ├── claude-code/
│   ├── codex/
│   ├── gemini-cli/
│   └── all/
├── references/              # 공통 워크플로우
│   └── workflow.md
├── config/                  # 소스 설정
│   └── sources.md
└── data/                    # 스냅샷 저장
    └── snapshots/
```
