---
name: load
description: |
  저장된 Task List를 선택하여 새 Claude Code 세션에 로드합니다.
  Trigger: "/tasklist:load", "태스크 리스트 불러와", "태스크 리스트 로드",
  "task list 열어줘", "태스크 리스트 로드해줘"
allowed-tools:
  - Bash
  - AskUserQuestion
user-invocable: true
---

# Task List — 로드

저장된 Task List를 선택하여 새 Warp 세션에 spawn합니다.

## 인자 지원

`$ARGUMENTS`가 있으면 목록 조회를 건너뛰고 바로 Spawn으로 진행한다.

## Step 1: 목록 조회 + 선택 (인자 없을 때만)

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

출력 후 AskUserQuestion으로 선택받는다:
- 상위 2~3개를 옵션으로 제공 (in_progress > pending 순)
- 나머지는 "Other"로 번호/이름 직접 입력

## Step 2: Spawn

선택 즉시 spawn. 상세 태스크 목록은 표시하지 않음 (새 세션에서 Ctrl+T로 확인).

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
