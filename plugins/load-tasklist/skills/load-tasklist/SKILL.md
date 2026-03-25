---
name: load-tasklist
description: |
  Browse saved Task Lists and load one into a new Claude Code session.
  Trigger: "/load-tasklist", "태스크 리스트 불러와", "태스크 리스트 로드",
  "task list 열어줘", "어떤 태스크 리스트 있어?"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
user-invocable: true
---

# Load Task List

`~/.claude/tasks/`에 저장된 Task List를 조회하고, 선택한 리스트로 새 세션을 spawn합니다.

## Step 1: 목록 조회

```bash
ls ~/.claude/tasks/
```

각 디렉토리의 태스크 수와 진행률을 요약합니다:

```bash
# 각 디렉토리마다 실행
python3 -c "
import json, os, glob, sys
d = sys.argv[1]
files = glob.glob(os.path.join(d, '*.json'))
total = len(files)
done = sum(1 for f in files if json.load(open(f)).get('status') == 'completed')
pending = sum(1 for f in files if json.load(open(f)).get('status') == 'pending')
progress = sum(1 for f in files if json.load(open(f)).get('status') == 'in_progress')
name = os.path.basename(d)
print(f'{name}  ({done}/{total} done, {progress} in progress, {pending} pending)')
" ~/.claude/tasks/<DIR>
```

결과를 번호 매긴 선택지로 표시합니다:

```
저장된 Task Lists:

  1) claude-code-mastery    (6/68 done, 0 in progress, 62 pending)
  2) ai-autonomous-testing  (3/8 done, 1 in progress, 4 pending)
  3) comment-yjs            (5/7 done, 0 in progress, 2 pending)
  ...

어떤 리스트를 로드할까요? (번호 또는 이름)
```

AskUserQuestion으로 선택을 받습니다.

## Step 2: 선택된 리스트 상세 표시

선택된 리스트의 전체 태스크를 테이블로 표시합니다:

```
📋 claude-code-mastery (6/68)

  #  Status       Subject
  1  ✅ completed  01. Overview — Claude Code 개요
  2  ✅ completed  02. Quickstart — 퀵스타트
  ...
  7  ⬜ pending    07. Skills — 커스텀 명령어/스킬
  8  ⬜ pending    08. Sub-agents — 서브에이전트
```

## Step 3: 액션 선택

AskUserQuestion으로 다음 중 선택:

- **새 세션에서 열기** (기본) → Step 4로
- **여기서 보기만** → 특정 태스크 상세 보기 (Read로 JSON 표시)
- **취소**

## Step 4: 새 세션 Spawn

`/spawn` 스킬의 Execution 패턴을 그대로 사용합니다.

명령어:
```bash
CLAUDE_CODE_TASK_LIST_ID=<selected-id> claude
```

AppleScript 실행:
```bash
osascript -e '
set the clipboard to "CLAUDE_CODE_TASK_LIST_ID=<selected-id> claude"
tell application "System Events"
    tell process "stable"
        click menu item "New Terminal Tab" of menu "File" of menu bar 1
        delay 3
        click menu item "Paste" of menu "Edit" of menu bar 1
        delay 1
        keystroke return
    end tell
end tell
'
```

**CRITICAL rules (from spawn skill):**
- Warp process name = `"stable"`, NOT `"Warp"`
- Use `Edit > Paste` menu, NOT Cmd+V
- Use `File > New Terminal Tab` menu, NOT Cmd+T
- delay 3 after tab open
- Set clipboard BEFORE opening tab
- `keystroke return` at end is REQUIRED

## Step 5: 완료 보고

```
✅ 새 세션에서 'claude-code-mastery' 태스크 리스트를 로드했습니다.
   Warp 새 탭에서 확인하세요. Ctrl+T로 태스크 목록을 볼 수 있습니다.
```

## 인자 지원

`/load-tasklist <id>` 형태로 직접 지정하면 Step 1을 건너뛰고 Step 2부터 시작합니다.
`$ARGUMENTS`가 있으면 해당 ID를 바로 사용.
