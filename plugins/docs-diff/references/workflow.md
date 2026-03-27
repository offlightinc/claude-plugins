# Docs Diff 공통 워크플로우

이 문서는 모든 docs-diff 스킬이 공유하는 워크플로우를 정의합니다.
각 SKILL.md에서 이 문서를 Read하여 참조합니다.

---

## Phase 0: 상태 확인

1. 해당 타겟의 snapshot 디렉토리를 Glob으로 확인
2. 기존 스냅샷 존재 여부 판별:
   - 스냅샷 있음 → **업데이트 모드** (diff 비교)
   - 스냅샷 없음 → **초기 수집 모드** (첫 스냅샷 생성, diff 스킵)

---

## Phase 1: Fetch

### Web 소스

1. **페이지 목록 수집**: Base URL의 sitemap.xml / 인덱스 / 사이드바 네비게이션에서 docs 페이지 URL 목록 추출
   - sitemap.xml 우선 사용
   - 없으면 인덱스 페이지의 네비게이션 링크 파싱
2. **각 페이지 fetch**: WebFetch로 HTML 가져옴
3. **Content 추출**: HTML → 깨끗한 Markdown
   - 네비게이션, 헤더, 푸터, 사이드바 등 비본문 요소 제거
   - 코드 블록, 테이블, 리스트 구조 보존
   - 이미지는 alt text + URL로 기록
4. **저장**: `data/snapshots/{target}/{source-type}/{page-slug}.md`
   - 파일 상단 메타데이터:
     ```markdown
     <!-- source: {원본 URL} -->
     <!-- fetched: {ISO 8601 timestamp} -->
     ```

### GitHub 소스

1. **파일 목록 수집**:
   ```bash
   gh api repos/{owner}/{repo}/contents/{docs-path} --jq '.[].path'
   ```
2. **각 파일 fetch**:
   ```bash
   gh api repos/{owner}/{repo}/contents/{file-path} --jq '.content' | base64 -d
   ```
3. **Markdown 그대로 저장** (추가 변환 불필요)
4. **저장**: 디렉토리 구조 유지, 메타데이터:
   ```markdown
   <!-- source: github:{owner}/{repo}/{file-path} -->
   <!-- fetched: {ISO 8601 timestamp} -->
   <!-- sha: {commit sha} -->
   ```

---

## Phase 2: 자가수복 (Self-Healing)

### 이상 감지 조건

다음 중 하나라도 해당하면 **크롤러 이상**으로 판단:
- 추출된 콘텐츠가 비어있음 (0 bytes)
- 이전 스냅샷 대비 20% 미만으로 짧음
- HTML 태그가 그대로 남아있음
- HTTP 에러 (403, 404, 500 등)
- 페이지 목록이 이전 대비 절반 이하로 감소

### Escalation Workflow (단계별 수복)

이상 감지 시, 아래 단계를 **순서대로** 시도합니다. 각 단계에서 성공하면 즉시 중단.

```
Step 1: 단순 재시도
  → WebFetch로 동일 URL 재요청 (일시적 오류 대응)
  → 성공? → 완료
  → 실패? → Step 2로

Step 2: 콘텐츠 추출 전략 변경
  → raw HTML을 가져와서 구조 분석
  → 본문 영역을 재식별 (main, article, .content 등)
  → 새 추출 전략으로 Markdown 변환 시도
  → 성공? → 완료 + 새 전략을 config/heal-log.md에 기록
  → 실패? → Step 3으로

Step 3: 대안 URL 탐색
  → WebSearch로 해당 docs의 새 URL 검색
    예: "Claude Code documentation site:anthropic.com"
  → sitemap.xml 재확인
  → 새 URL 발견? → Step 1부터 새 URL로 재시도
  → 실패? → Step 4로

Step 4: GitHub 소스 대체 (해당하는 경우)
  → 웹 크롤링 실패 시 GitHub 소스가 있으면 GitHub에서 가져오기
  → GitHub도 실패? → Step 5로

Step 5: 사용자 알림 및 스킵
  → 해당 소스를 스킵
  → 사용자에게 수동 확인 요청 메시지 출력:
    "⚠️ {source-id} 크롤링 실패. 수동 확인 필요: {URL}"
  → 다른 소스는 정상 진행
```

### 원인 분류 (로그용)

| 원인 | 설명 | 해당 Step |
|------|------|----------|
| `TRANSIENT_ERROR` | 일시적 네트워크/서버 오류 | Step 1 |
| `SELECTOR_BROKEN` | 콘텐츠 추출 실패 | Step 2 |
| `STRUCTURE_CHANGED` | 사이트 구조/URL 변경 | Step 3 |
| `ACCESS_DENIED` | 접근 차단 | Step 3~4 |
| `SITE_DOWN` | 사이트 다운 | Step 5 |
| `API_CHANGED` | GitHub API 응답 변경 | Step 2 (GitHub 소스) |

### 수복 로그 형식 (`config/heal-log.md`에 append)

```markdown
## {날짜} {source-id}
- 원인: {원인 분류}
- 상세: {구체적 설명}
- 수복: {적용한 전략}
- 결과: {성공/실패}
```

---

## Phase 3: Diff 감지

1. Bash로 git diff 실행:
   ```bash
   git diff --no-color -- data/snapshots/{target}/
   ```
2. 변경 유형 분류:
   - **NEW**: 새로 추가된 페이지/파일
   - **MODIFIED**: 내용 변경
   - **DELETED**: 삭제됨
3. 변경 없으면 "변경 없음" 보고

**초기 수집 모드에서는 Phase 3~4 스킵.**

---

## Phase 4: 상세 변경 리포트

### 필수 포함 요소 (NON-NEGOTIABLE)

각 변경사항에 대해 반드시 3가지를 포함:

1. **무엇이 바뀌었는가 (What)** — 변경된 사실을 명확하게
2. **왜 중요한가 (Why)** — 배경과 맥락, 어떤 문제를 해결하는지, 어떤 방향성인지
3. **실제 사용에 어떤 영향이 있는가 (Impact)** — 사용자가 알아야 할 것, 기존 워크플로우 영향

### 리포트 출력 형식 (단일 타겟)

```markdown
# {타겟명} Docs 변경 리포트 — {날짜}

## 요약
- {소스 수}개 소스 중 {N}개에서 변경 감지
- 주요 변경: {가장 중요한 1-2개 한 줄 요약}

---

## [{소스명}]

### ✦ {파일명} — {변경 제목}

**무엇이 바뀌었는가:**
{사실 기반 설명}

**왜 중요한가:**
{배경, 맥락, 방향성}

**실제 영향:**
- {구체적 영향 1}
- {구체적 영향 2}

---

## 크롤러 상태
| 소스 | 상태 | 비고 |
|------|------|------|
| {source} | ✅ 정상 / 🔧 수복됨 / ❌ 실패 | {비고} |
```

### 리포트 출력 형식 (전체 - all)

all 스킬 실행 시에는 3개 타겟의 리포트를 통합하되, **크로스 레퍼런스**를 추가:

```markdown
# AI Coding Tools Docs 변경 리포트 — {날짜}

## 전체 요약
- Claude Code: {변경 N건 / 변경 없음}
- OpenAI Codex: {변경 N건 / 변경 없음}
- Gemini CLI: {변경 N건 / 변경 없음}
- 크로스 레퍼런스: {공통 변경 있으면 언급}

---

## Claude Code
{개별 리포트}

## OpenAI Codex
{개별 리포트}

## Gemini CLI
{개별 리포트}

---

## 크로스 레퍼런스
{여러 제품에서 유사한 변경이 있으면 비교 분석}
```

### 리포트 규칙

- **CRITICAL**: diff 나열 금지. 반드시 Why + Impact 포함
- docs에 실제 기재된 내용만 근거. 추측 금지
- 코드 예시가 docs에 있으면 리포트에도 포함
- 여러 소스에서 같은 기능 변경 시 크로스 레퍼런스

---

## Phase 5: 스냅샷 저장

1. Phase 1에서 이미 파일 Write 완료
2. **커밋은 하지 않는다** — 사용자가 직접 결정

---

## 공통 규칙

1. **독립성**: 각 소스는 독립적. 한 소스 실패가 다른 소스에 영향 주지 않음
2. **자가수복 우선**: 이상 감지 시 먼저 자동 수복. 실패 시에만 사용자 알림
3. **상세 설명 필수**: diff만 보여주는 것 금지. What + Why + Impact
4. **사실 기반**: docs 기재 내용만 근거. 추측 금지
5. **커밋 금지**: 자동 커밋 안 함
6. **메타데이터 보존**: 각 스냅샷에 source URL + fetch 시간 유지

---

## Common Pitfalls

웹 크롤링 + diff 분석 스킬에서 자주 발생하는 함정:

### 크롤링 관련

1. **Rate limiting 무시**: 한 사이트에 대해 WebFetch를 빠르게 연속 호출하면 차단될 수 있음. 같은 도메인에 대해 과도한 병렬 요청을 하지 말 것
2. **SPA 콘텐츠 누락**: JavaScript로 렌더링되는 콘텐츠는 WebFetch로 가져올 수 없음. 빈 결과가 나오면 사이트가 SPA인지 확인하고 대안 탐색 (API, GitHub 소스 등)
3. **Encoding 깨짐**: UTF-8이 아닌 페이지에서 한글/특수문자가 깨질 수 있음. 메타데이터의 charset 확인
4. **Redirect 미추적**: URL이 리다이렉트되면 원본 URL로는 빈 결과. 최종 URL을 추적하여 저장
5. **로그인 벽**: 일부 docs는 인증이 필요할 수 있음. 접근 불가 시 즉시 사용자에게 알리고 해당 소스 스킵

### Diff 분석 관련

6. **메타데이터 변경을 실제 변경으로 오인**: fetched timestamp가 바뀌었을 뿐인데 "변경됨"으로 보고하지 말 것. 메타데이터 라인(<!-- -->)은 diff에서 제외
7. **공백/포맷 변경 과잉 보고**: 들여쓰기나 줄바꿈만 바뀐 건 실질적 변경이 아님. 의미있는 콘텐츠 변경만 보고
8. **삭제된 페이지 = 문제로 단정**: 페이지가 사라졌다고 바로 "삭제됨"으로 보고하기 전에 URL 변경(이동) 여부를 먼저 확인

### 리포트 관련

9. **추측 기반 Why/Impact**: docs에 없는 내용을 추측해서 "이것은 아마 ~때문일 것"이라고 쓰지 말 것. 모르면 "변경 배경은 docs에 기재되지 않음"이라고 명시
10. **크로스 레퍼런스 강제**: 관련 없는 변경을 억지로 연결하지 말 것. 실제 연관이 있을 때만
