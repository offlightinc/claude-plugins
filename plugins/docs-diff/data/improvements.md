# docs-diff 개선점 목록

## Iteration 1 발견사항

### 1. [HIGH] `disable-model-invocation: true` 누락
- **문제**: 모든 스킬에 이 설정이 없어서 Claude가 자동으로 호출할 수 있음
- **이유**: docs fetch/write는 부작용이 있는 작업. 공식 docs에서 "side-effects가 있는 스킬은 disable-model-invocation: true 권장"
- **출처**: code.claude.com/docs/en/skills

### 2. [HIGH] `effort: high` 누락
- **문제**: effort 레벨 미지정으로 기본값 사용
- **이유**: 5개 소스를 크롤링하고 diff 분석하는 건 명백히 high effort 작업
- **출처**: code.claude.com/docs/en/skills

### 3. [HIGH] 개별 SKILL.md가 너무 빈약
- **문제**: claude-code, codex, gemini-cli 스킬이 "workflow.md 읽고 실행"만 기재
- **이유**: 공식 패턴은 각 SKILL.md가 standalone으로 충분한 context를 가져야 함. Progressive disclosure 원칙 — 스킬 본문은 <5000 tokens, 상세는 references/
- **출처**: anthropics/skills 레포, code.claude.com/docs/en/skills

### 4. [MEDIUM] Common Pitfalls / Best Practices 섹션 없음
- **문제**: workflow.md에 규칙은 있지만 "하지 말아야 할 것" 패턴이 부족
- **이유**: 인기 스킬들은 모두 pitfalls 섹션을 포함. 크롤링 스킬은 특히 함정이 많음
- **출처**: alirezarezvani/claude-skills (5200+ stars)

### 5. [MEDIUM] metadata 필드 없음
- **문제**: plugin.json에는 version이 있지만 SKILL.md frontmatter에 metadata 없음
- **이유**: 공식 스펙에서 metadata 필드로 version, author 등 추적 가능
- **출처**: agentskills.io/specification

### 6. [LOW] description 키워드 부족
- **문제**: 트리거 구문이 제한적. 영문 변형이 부족
- **이유**: 더 많은 키워드 → 자동 invocation 정확도 향상
- **출처**: code.claude.com/docs/en/skills

### 7. [LOW] expected output 예시 없음 → ✅ 적용 (Iteration 7)
- **문제**: 리포트 형식을 template로만 제시, 실제 예시 없음
- **이유**: alirezarezvani/claude-skills에서 expected_outputs/ 디렉토리 패턴 사용
- **적용**: references/example-report.md 생성 (단일 타겟 + 크로스 레퍼런스 예시)

## Iteration 2 발견사항

### 8. [HIGH] allowed-tools 과다 허용 (Over-permissioning)
- **문제**: 모든 스킬이 동일한 9개 도구를 허용. 개별 스킬에 불필요한 도구 포함
- **이유**: Deep dive 블로그에서 anti-pattern으로 지적. "Include only necessary tools"
- **출처**: leehanchung deep dive blog, code.claude.com/docs/en/plugins
- **적용**: 개별 스킬은 Edit 제거 (전체 파일 Write만 사용), all 스킬은 Agent 필수 유지

### 9. [MEDIUM] README.md 없음
- **문제**: 플러그인 루트에 README.md가 없음
- **이유**: 공식 플러그인 구조에 README.md 포함. 사용자가 설치 전 이해할 수 있어야 함
- **출처**: code.claude.com/docs/en/plugins

### 10. [MEDIUM] Common Pitfalls 미적용 (Iteration 1에서 발견 → 아직 미적용)
- workflow.md에 크롤링 특화 pitfalls 추가 필요

### 11. [LOW] settings.json 미활용
- **문제**: 플러그인 레벨 기본 설정 파일이 없음
- **이유**: 공식 docs에서 settings.json으로 기본 agent 등 설정 가능
- **적용 보류**: 현재 필요한 기본 설정이 없으므로 나중에 필요 시 추가

## Iteration 4 발견사항

### 12. [HIGH] 자가수복 escalation workflow 부재
- **문제**: workflow.md의 자가수복이 "raw HTML 분석 → 새 추출 전략"으로 모호
- **이유**: Firecrawl 플러그인은 concrete escalation 패턴 사용 (Search → Scrape → Map → Crawl → Browser). 각 단계에서 실패 시 다음 단계로 자동 전환. 우리도 자가수복에 명확한 단계별 escalation이 필요
- **출처**: firecrawl/firecrawl-claude-plugin

### 13. [MEDIUM] description 시작 패턴 비준수
- **문제**: 스킬 description이 "... 변경사항을 추적하고" 식으로 시작
- **이유**: plugin-dev 권장: "This skill should be used when..." 패턴으로 시작해야 auto-discovery 정확도 향상
- **출처**: sjnims/plugin-dev
