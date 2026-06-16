#!/usr/bin/env python3
"""
Coding Agent – Mycelial Network
Reads its definition, follows hooks, and executes code tasks.
"""

import os
import sys
import json
import subprocess
from datetime import datetime
import argparse

# Paths
BASE_DIR = os.path.expanduser("~/mycelial")
DEFINITION_FILE = os.path.join(BASE_DIR, "agents", "codingagent.md")
STATE_FILE = os.path.join(BASE_DIR, "state", "codingagent.json")
LOG_FILE = os.path.join(BASE_DIR, "logs", "audit.log")
SOURCE_OF_TRUTH = os.path.join(BASE_DIR, "README.md")
HOOK_PRE_EDIT = os.path.join(BASE_DIR, "hooks", "pre_edit.sh")
HOOK_POST_EDIT = os.path.join(BASE_DIR, "hooks", "post_edit.sh")

def log(message):
    timestamp = datetime.now().isoformat()
    with open(LOG_FILE, "a") as f:
        f.write(f"{timestamp} | codingagent | {message}\n")
    print(message)

def read_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    return {"last_task": None, "pending": [], "errors": []}

def write_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

def run_hook(hook_path, *args):
    if not os.path.exists(hook_path):
        log(f"⚠️ Hook {hook_path} not found. Skipping.")
        return True, ""
    cmd = [hook_path] + list(args)
    result = subprocess.run(cmd, capture_output=True, text=True)
    output = result.stdout + result.stderr
    if result.returncode == 0:
        log(f"✅ Hook {hook_path} passed.")
        return True, output
    else:
        log(f"❌ Hook {hook_path} failed:\n{output}")
        return False, output

def read_definition():
    if os.path.exists(DEFINITION_FILE):
        with open(DEFINITION_FILE, "r") as f:
            return f.read()
    log("⚠️ No definition file found. Using default behavior.")
    return ""

def read_source_of_truth():
    if os.path.exists(SOURCE_OF_TRUTH):
        with open(SOURCE_OF_TRUTH, "r") as f:
            return f.read()
    log("⚠️ Source of truth not found. Proceeding with caution.")
    return ""

def edit_file(filepath, new_content):
    success, output = run_hook(HOOK_PRE_EDIT, filepath)
    if not success:
        log(f"❌ pre_edit hook failed. Aborting edit.")
        return False
    try:
        with open(filepath, "w") as f:
            f.write(new_content)
        log(f"✏️ Edited file: {filepath}")
    except Exception as e:
        log(f"❌ Failed to write file: {e}")
        return False
    success, output = run_hook(HOOK_POST_EDIT, filepath)
    if not success:
        log(f"❌ post_edit hook failed. Rolling back...")
        return False
    return True

def main():
    parser = argparse.ArgumentParser(description="Mycelial Coding Agent")
    parser.add_argument("--task", required=True, help="Task to execute (e.g., 'edit ~/AgTechAI/client.py')")
    parser.add_argument("--content", help="New content for the file (if editing)")
    args = parser.parse_args()

    log("🧠 Coding Agent started.")
    log(f"📖 Task: {args.task}")

    read_source_of_truth()
    read_definition()

    state = read_state()
    state["last_task"] = args.task
    state["last_run"] = datetime.now().isoformat()

    if args.task.startswith("edit "):
        filepath = args.task.replace("edit ", "").strip()
        if not args.content:
            log("❌ No content provided for edit task.")
            sys.exit(1)
        success = edit_file(filepath, args.content)
        if success:
            log(f"✅ File {filepath} edited successfully.")
        else:
            log(f"❌ Editing {filepath} failed.")
            state["errors"].append({"task": args.task, "timestamp": datetime.now().isoformat()})
    else:
        log(f"⚠️ Unsupported task: {args.task}")

    write_state(state)
    log("🧠 Coding Agent finished.")
    sys.exit(0)

if __name__ == "__main__":
    main()
