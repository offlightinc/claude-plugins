# Research Log

## Iteration 1 — 2026-03-27

### 조사한 레포

| 레포 | Stars | 주요 발견 |
|------|-------|----------|
| [anthropics/skills](https://github.com/anthropics/skills) | 공식 | template/, references/ 패턴, progressive disclosure, <500 lines 권장 |
| [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) | 공식 docs | frontmatter 전체 스펙 (effort, context, disable-model-invocation 등) |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | 5200+ | Common Pitfalls, Best Practices, Decision Framework, expected_outputs/ 패턴 |

### 추출한 Best Practice 패턴

1. **frontmatter 완성도**: effort, disable-model-invocation, metadata 활용
2. **Progressive disclosure**: SKILL.md <500 lines, 상세는 references/에 분리
3. **Standalone 스킬**: 각 SKILL.md가 references/ 없이도 기본 동작 가능해야 함
4. **Common Pitfalls 섹션**: 크롤링 특화 함정 (rate limiting, 구조 변경, encoding 등)
5. **Decision tree**: 자가수복 시 어떤 전략을 쓸지 판단 흐름도

### 적용한 개선

1. 4개 SKILL.md에 `disable-model-invocation: true`, `effort: high` 추가
2. 개별 SKILL.md 본문 강화 (standalone context 추가)

---

## Iteration 2 — 2026-03-27

### 조사한 레포

| 레포 | Stars | 주요 발견 |
|------|-------|----------|
| [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins) | 공식 docs | plugin 표준 구조 (README.md 포함), settings.json, --plugin-dir 테스트 |
| [leehanchung deep dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) | 블로그 | Over-permissioning anti-pattern, progressive disclosure 심화, meta-tool 패턴 |

### 추출한 Best Practice 패턴

1. **Over-permissioning 방지**: allowed-tools를 스킬별로 최소한으로 제한
2. **README.md 필수**: 플러그인 루트에 사용자 안내 문서
3. **Common Pitfalls**: 크롤링 + diff 특화 함정 목록

### 적용한 개선

1. workflow.md에 Common Pitfalls 섹션 추가 (10개 항목)
2. README.md 작성 (설치, 사용법, 구조 안내)

### 누적 조사 레포: 5개 (최소 요구 충족)

---

## Iteration 3 — 2026-03-27

### 적용한 개선

1. allowed-tools 과다 허용 수정 (Over-permissioning fix):
   - claude-code: Edit, Grep, Agent 제거 (소스 1개, 병렬 불필요)
   - codex, gemini-cli: Edit, Grep 제거 (Agent 유지 — 병렬 web+github fetch)
   - all: Edit, Grep 제거 (Agent 유지 — 3개 타겟 병렬)

### 전체 개선 적용 현황

| # | 우선순위 | 항목 | 상태 |
|---|---------|------|------|
| 1 | HIGH | disable-model-invocation | ✅ |
| 2 | HIGH | effort: high | ✅ |
| 3 | HIGH | SKILL.md 본문 강화 | ✅ |
| 4 | MEDIUM | Common Pitfalls | ✅ |
| 5 | MEDIUM | metadata 필드 | 보류 (저가치) |
| 6 | LOW | description 키워드 | ✅ |
| 7 | LOW | expected output | 보류 (첫 실행 후 생성) |
| 8 | HIGH | Over-permissioning | ✅ |
| 9 | MEDIUM | README.md | ✅ |
| 10 | MEDIUM | Common Pitfalls 적용 | ✅ |
| 11 | LOW | settings.json | 보류 (불필요) |

---

## Iteration 4 — 2026-03-27

### 조사한 레포

| 레포 | Stars | 주요 발견 |
|------|-------|----------|
| [firecrawl/firecrawl-claude-plugin](https://github.com/firecrawl/firecrawl-claude-plugin) | 공식 | Escalation workflow (Search→Scrape→Map→Crawl→Browser), context-aware output 패턴 |
| [sjnims/plugin-dev](https://github.com/sjnims/plugin-dev) | 개발 툴킷 | Description "should be used when..." 패턴, ${CLAUDE_PLUGIN_ROOT} 경로, 검증 체크리스트 |

### 추출한 Best Practice 패턴

1. **Escalation workflow**: 자가수복을 단계별 구체적 흐름으로 (모호한 "분석" 대신)
2. **Description trigger 패턴**: "This skill should be used when..." 시작
3. **검증 체크리스트**: plugin-validator, validate-hook-schema 등 배포 전 검증

### 적용한 개선

1. workflow.md 자가수복 → 5단계 Escalation Workflow로 교체 (Step 1~5 concrete 흐름)

### 누적 조사 레포: 7개

### 전체 개선 적용 현황 (업데이트)

| # | 우선순위 | 항목 | 상태 |
|---|---------|------|------|
| 1 | HIGH | disable-model-invocation | ✅ |
| 2 | HIGH | effort: high | ✅ |
| 3 | HIGH | SKILL.md 본문 강화 | ✅ |
| 4 | MEDIUM | Common Pitfalls | ✅ |
| 5 | MEDIUM | metadata 필드 | 보류 (저가치) |
| 6 | LOW | description 키워드 | ✅ |
| 7 | LOW | expected output | 보류 (첫 실행 후 생성) |
| 8 | HIGH | Over-permissioning | ✅ |
| 9 | MEDIUM | README.md | ✅ |
| 10 | MEDIUM | Common Pitfalls 적용 | ✅ |
| 11 | LOW | settings.json | 보류 (불필요) |
| 12 | HIGH | Escalation workflow | ✅ |
| 13 | MEDIUM | Description 패턴 | 보류 (disable-model-invocation=true이므로 auto-discovery 무관) |

---

## Iteration 6 — 2026-03-27

### 적용한 개선

1. metadata 필드 추가 (#5): 4개 SKILL.md에 version, author, sources metadata 추가

### 전체 개선 적용 현황 (최종)

| # | 우선순위 | 항목 | 상태 |
|---|---------|------|------|
| 1 | HIGH | disable-model-invocation | ✅ |
| 2 | HIGH | effort: high | ✅ |
| 3 | HIGH | SKILL.md 본문 강화 | ✅ |
| 4 | MEDIUM | Common Pitfalls | ✅ |
| 5 | MEDIUM | metadata 필드 | ✅ |
| 6 | LOW | description 키워드 | ✅ |
| 7 | LOW | expected output | 보류 (첫 실행 후 생성) |
| 8 | HIGH | Over-permissioning | ✅ |
| 9 | MEDIUM | README.md | ✅ |
| 10 | MEDIUM | Common Pitfalls 적용 | ✅ |
| 11 | LOW | settings.json | 보류 (불필요) |
| 12 | HIGH | Escalation workflow | ✅ |
| 13 | MEDIUM | Description 패턴 | 보류 |

### 결론

- HIGH 5건 모두 적용 완료
- MEDIUM 5건 중 4건 적용, 1건 보류
- LOW 3건 중 1건 적용, 2건 보류
- 7개 외부 소스 조사 완료
- 10/13 개선점 적용, 3건 합리적 보류

---

## Iteration 7 — 2026-03-27

### 적용한 개선

1. expected output 예시 추가 (#7): references/example-report.md 생성
   - 단일 타겟 리포트 예시 (What/Why/Impact 전체 포함)
   - 전체 타겟 크로스 레퍼런스 예시

### 최종 적용 현황: 11/13 적용, 2건 보류 (settings.json 불필요, description 패턴 무관)

---

## Iteration 8 (Final) — 2026-03-27

### 최종 검증

플러그인 구조 확인:
- plugin.json ✅
- README.md ✅
- config/sources.md ✅
- references/workflow.md ✅ (Common Pitfalls + Escalation Workflow 포함)
- references/example-report.md ✅
- skills/claude-code/SKILL.md ✅ (standalone, minimal tools, metadata)
- skills/codex/SKILL.md ✅ (standalone, Agent 포함, metadata)
- skills/gemini-cli/SKILL.md ✅ (standalone, Agent 포함, metadata)
- skills/all/SKILL.md ✅ (standalone, Agent 포함, metadata, 크로스 레퍼런스)

Best Practice 적용 요약:
- [anthropics/skills] progressive disclosure, references/ 분리 ✅
- [code.claude.com/skills] frontmatter 완성도 (effort, disable-model-invocation, metadata) ✅
- [alirezarezvani/claude-skills] Common Pitfalls, expected output ✅
- [code.claude.com/plugins] README.md, 표준 디렉토리 구조 ✅
- [leehanchung deep dive] Over-permissioning 방지 ✅
- [firecrawl plugin] Escalation workflow ✅
- [sjnims/plugin-dev] 검증 패턴 참조 ✅

### Ralph Loop 완료 — 8 iterations, 7개 소스 조사, 11/13 개선 적용
