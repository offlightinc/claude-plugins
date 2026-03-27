# Skill & Plugin Best Practices

Claude Code 스킬/플러그인 제작 시 참고할 best practice 가이드.
7개 외부 소스(공식 2개, 커뮤니티 3개, 블로그 2개)에서 추출한 공통 패턴.

---

## 1. Progressive Disclosure (필요한 만큼만 보여주기)

**가장 중요한 원칙.** Claude의 context window를 효율적으로 사용한다.

```
Level 1: description (~100 tokens) — Claude가 "이 스킬 쓸까?" 판단
Level 2: SKILL.md 본문 (<5000 tokens) — 활성화 시 로드
Level 3: references/, scripts/ — 필요할 때만 온디맨드 로드
```

- SKILL.md는 **500 lines 이하** 유지
- 상세 내용은 `references/`로 분리
- 단, 각 SKILL.md는 **references 없이도 기본 동작 가능**해야 함 (standalone)

## 2. Frontmatter 설계

| 필드 | 용도 | 언제 쓰나 |
|------|------|----------|
| `name` | 스킬 식별자 | 항상 |
| `description` | Claude의 auto-discovery + 사용자 안내 | 항상. 키워드 풍부하게 (한+영) |
| `disable-model-invocation` | 자동 호출 방지 | **부작용 있는 스킬은 필수** (파일 쓰기, 외부 호출, 배포 등) |
| `effort` | 작업 무게 힌트 | 무거운 작업(크롤링, 빌드, 분석 등)은 `high` |
| `allowed-tools` | 도구 접근 제한 | 항상. **최소 권한 원칙** 적용 |
| `metadata` | 버전, 작성자 등 | 공유/배포할 플러그인에서 |
| `user-invocable` | 사용자 직접 호출 가능 여부 | 배경 지식용 스킬은 `false` |

## 3. 최소 권한 (Least Privilege)

**Over-permissioning은 anti-pattern.**

```yaml
# BAD — 모든 도구 나열
allowed-tools: [WebFetch, WebSearch, Read, Write, Edit, Glob, Grep, Bash, Agent]

# GOOD — 실제 필요한 것만
allowed-tools: [Read, Write, Glob, Bash]
```

- 스킬마다 **실제로 사용하는 도구만** 허용
- 같은 플러그인 내 스킬이라도 각각 다르게 설정
- 읽기만 하는 스킬에 Write/Edit를 주지 않음

## 4. 디렉토리 구조

```
plugin-name/
├── .claude-plugin/plugin.json   ← 이것만 .claude-plugin/ 안에
├── README.md                    ← 필수. 설치 전 이해용
├── skills/
│   └── skill-name/
│       └── SKILL.md
├── references/                  ← 공통 상세 문서
├── scripts/                     ← 실행 스크립트 (Python, Bash)
├── config/                      ← 설정 파일
└── data/                        ← 런타임 데이터
```

**절대 규칙**: commands/, agents/, skills/, hooks/를 `.claude-plugin/` 안에 넣지 않음. `.claude-plugin/`에는 `plugin.json`만.

## 5. 에러 핸들링 = Escalation Workflow

모호한 "에러 시 분석" 대신 **구체적 단계별 흐름**을 정의한다.

```
Step 1: 단순 재시도 (일시적 오류)
  → 실패 시
Step 2: 전략 변경 (다른 방법으로 같은 목표)
  → 실패 시
Step 3: 대안 탐색 (다른 소스/경로)
  → 실패 시
Step 4: 사용자 알림 + 해당 작업 스킵
```

핵심: "재시도"가 아니라 **도구 전환**(tool substitution). 같은 방법을 반복하지 않고 다른 접근을 시도.

## 6. SKILL.md 본문 구성

인기 스킬들의 공통 섹션 구조:

```markdown
# 스킬명
{한 줄 설명}

## 소스/대상
{이 스킬이 다루는 대상}

## 실행 워크플로우
{단계별 절차 — 구체적 도구/명령어 포함}

## Common Pitfalls
{하지 말아야 할 것 목록}

## 규칙
{NON-NEGOTIABLE 제약}
```

- **Common Pitfalls 섹션은 거의 필수** — 뭘 하면 안 되는지 명시
- 코드 예시는 pseudocode 아닌 **실제 실행 가능한 명령어**로
- 스킬의 도메인 특화 함정을 구체적으로 나열

## 7. 공유 로직 처리

여러 스킬이 같은 로직을 쓸 때 **하이브리드 방식** 추천:

```
SKILL.md에 핵심 흐름은 인라인으로 (standalone 보장)
상세/공통 부분만 references/로 분리 (중복 제거)
```

| 방식 | 장점 | 단점 |
|------|------|------|
| references/에 전부 위임 | 중복 없음 | standalone 불가 |
| 각 SKILL.md에 전부 인라인 | 완전 standalone | 중복, 동기화 어려움 |
| **하이브리드** | 둘 다 | — |

## 8. 개발 편의

- **테스트**: `claude --plugin-dir ./my-plugin`으로 설치 없이 바로 테스트
- **리로드**: `/reload-plugins`로 재시작 없이 변경 반영
- **예시 출력**: `references/`에 실제 출력 예시를 포함하면 Claude가 형식을 정확히 따름
- **description 키워드**: 한국어 + 영어 트리거를 모두 넣으면 auto-discovery 정확도 향상

---

## 출처

이 가이드는 다음 소스들에서 추출한 패턴을 종합한 것:

| 소스 | 핵심 기여 |
|------|----------|
| [anthropics/skills](https://github.com/anthropics/skills) | Progressive disclosure, references/ 패턴, 공식 template |
| [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) | Frontmatter 전체 스펙, effort/context/disable-model-invocation |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) (5200+ stars) | Common Pitfalls, Decision Framework, expected_outputs/ |
| [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins) | Plugin 표준 구조, README.md, --plugin-dir 테스트 |
| [leehanchung deep dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) | Over-permissioning anti-pattern, meta-tool 패턴 |
| [firecrawl/firecrawl-claude-plugin](https://github.com/firecrawl/firecrawl-claude-plugin) | Escalation workflow, context-aware output |
| [sjnims/plugin-dev](https://github.com/sjnims/plugin-dev) | Description trigger 패턴, 검증 체크리스트 |
