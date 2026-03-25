---
name: load-tasklist
description: |
  Browse saved Task Lists and load one into a new Claude Code session.
  Trigger: "/load-tasklist", "태스크 리스트 불러와", "태스크 리스트 로드",
  "task list 열어줘", "어떤 태스크 리스트 있어?"
allowed-tools:
  - Bash
  - AskUserQuestion
user-invocable: true
---

# Load Task List

`~/.claude/tasks/`에 저장된 Task List를 조회하고, 선택한 리스트로 새 세션을 spawn합니다.

## Step 1: 목록 조회 + 선택

**단일 Bash 호출**로 이름 있는 디렉토리만 필터링하고 진행률을 한번에 출력합니다:

```bash
python3 -c "
import json, os, glob, re
base = os.path.expanduser('~/.claude/tasks')
dirs = sorted([d for d in os.listdir(base)
               if os.path.isdir(os.path.join(base, d))
               and not re.match(r'^[0-9a-f]{8}-', d)])
for i, name in enumerate(dirs, 1):
    path = os.path.join(base, name)
    files = glob.glob(os.path.join(path, '*.json'))
    total = len(files)
    if total == 0:
        continue
    done = 0; prog = 0; pend = 0
    for f in files:
        try:
            s = json.load(open(f)).get('status','')
            if s == 'completed': done += 1
            elif s == 'in_progress': prog += 1
            elif s == 'pending': pend += 1
        except: pass
    print(f'  {i:2d}) {name:<35s} {done}/{total} done, {prog} in progress, {pend} pending')
"
```

출력 결과를 그대로 보여준 뒤, AskUserQuestion으로 **번호 또는 이름**을 입력받습니다.

AskUserQuestion 옵션:
- 상위 2~3개 리스트를 옵션으로 제공 (진행중 > pending 순 우선)
- 나머지는 사용자가 "Other"로 번호/이름 직접 입력

## Step 2: Spawn

선택 즉시 spawn합니다. 상세 태스크 목록은 표시하지 않음 (새 세션에서 Ctrl+T로 확인).

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

## Step 3: 완료 보고

```
Done — '<name>' 로드됨. Warp 새 탭에서 Ctrl+T로 확인하세요.
```

## 인자 지원

`/load-tasklist <id>` 형태로 직접 지정하면 Step 1을 건너뛰고 바로 Step 2로 진행합니다.
`$ARGUMENTS`가 있으면 해당 ID를 바로 사용.
