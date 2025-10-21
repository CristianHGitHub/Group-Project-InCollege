#!/usr/bin/env python3
import os
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from typing import List


@dataclass
class TestCase:
    name: str = "(unnamed)"
    reset_accounts: bool = False
    input_lines: List[str] = field(default_factory=list)
    expected_lines: List[str] = field(default_factory=list)


def rtrim(s: str) -> str:
    return s.rstrip("\r\n \t")


def parse_tests(path: str) -> List[TestCase]:
    tests: List[TestCase] = []
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    with open(path, "r", encoding="utf-8") as f:
        lines = [rtrim(l) for l in f.readlines()]

    state = "OUT"  # OUT, TEST, INPUT, EXPECTED
    cur = TestCase()
    for line in lines:
        if state in ("OUT", "TEST"):
            if line.startswith("#"):
                continue
        if state == "OUT":
            if line.startswith("Test:"):
                cur = TestCase()
                cur.name = rtrim(line[5:].lstrip()) or "(unnamed)"
                state = "TEST"
            elif line == "":
                continue
            else:
                # ignore stray
                continue
        elif state == "TEST":
            if line.lower().startswith("resetaccounts:"):
                v = line.split(":", 1)[1].strip().lower()
                cur.reset_accounts = v in ("yes", "true", "1")
            elif line.lower() == "input:":
                state = "INPUT"
            elif line == "":
                continue
            else:
                # ignore unknown directives
                pass
        elif state == "INPUT":
            if line.lower() == "expected:":
                state = "EXPECTED"
            else:
                cur.input_lines.append(line)
        elif state == "EXPECTED":
            if line.lower() in ("end", "endtest"):
                tests.append(cur)
                cur = TestCase()
                state = "OUT"
            else:
                cur.expected_lines.append(line)

    if state == "EXPECTED" and cur.expected_lines:
        tests.append(cur)
    return tests


def ensure_truncated(path: str):
    with open(path, "w", encoding="utf-8"):
        pass


def write_lines(path: str, lines: List[str]):
    with open(path, "w", encoding="utf-8") as f:
        for ln in lines:
            f.write(ln + "\n")


def read_lines(path: str) -> List[str]:
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        return [rtrim(l) for l in f.readlines()]


def run_tests(test_file: str, export: bool = False) -> int:
    tests = parse_tests(test_file)
    if not tests:
        print(f"No tests found in {test_file}")
        return 1

    # Ensure COBOL app exists
    if not os.path.exists("bin/InCollege"):
        print("bin/InCollege not found. Build the project first (e.g., make).")

    start_cwd = os.getcwd()
    # Prepare export directories (in repo root) if requested
    export_root = Path(start_cwd) / "export"
    export_in_dir = export_root / "input"
    export_out_dir = export_root / "output"
    testfile_stem = Path(test_file).name
    testfile_stem = Path(testfile_stem).stem  # base name without extension
    if export:
        export_in_dir.mkdir(parents=True, exist_ok=True)
        export_out_dir.mkdir(parents=True, exist_ok=True)
    os.chdir("bin")
    in_path = "../data/InCollege-Input.txt"
    out_path = "../data/InCollege-Output.txt"
    acct_path = "../data/AccountRecords.txt"
    conn_path = "../data/ConnectionRecords.txt"
    established_path = "../data/EstablishedConnections.txt"
    profile_path = "../data/ProfileRecords.txt"
    job_path = "../data/JobPostings.txt"

    passed = 0
    failed = 0
    for idx, tc in enumerate(tests, start=1):
        print(f"[{idx}/{len(tests)}] {tc.name}")
        ensure_truncated(out_path)
        if tc.reset_accounts:
            ensure_truncated(acct_path)
            ensure_truncated(conn_path)
            ensure_truncated(profile_path)
            ensure_truncated(established_path)
            # Also clear job postings between tests when resetting accounts
            ensure_truncated(job_path)
        write_lines(in_path, tc.input_lines)

        try:
            subprocess.run(["./InCollege"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        except subprocess.CalledProcessError as e:
            print(f"  ERROR: InCollege exited with code {e.returncode}")
            failed += 1
            # Export input (only) for crash cases if requested
            if export:
                case_name = f"{testfile_stem}-{idx}.txt"
                write_lines(str(export_in_dir / case_name), tc.input_lines)
            continue

        actual = read_lines(out_path)
        # Export input and actual output if requested
        if export:
            case_name = f"{testfile_stem}-{idx}.txt"
            write_lines(str(export_in_dir / case_name), tc.input_lines)
            write_lines(str(export_out_dir / case_name), actual)
        exp = tc.expected_lines
        max_len = max(len(exp), len(actual))
        ok = True
        mismatch_idx = -1
        for i in range(max_len):
            e = exp[i] if i < len(exp) else ""
            a = actual[i] if i < len(actual) else ""
            if e != a:
                ok = False
                mismatch_idx = i
                break
        if ok:
            print(f"  PASS ({len(actual)} lines)")
            passed += 1
        else:
            print(f"  FAIL at line {mismatch_idx+1}")
            e = exp[mismatch_idx] if mismatch_idx < len(exp) else ""
            a = actual[mismatch_idx] if mismatch_idx < len(actual) else ""
            print(f"    expected: {e}")
            print(f"    actual  : {a}")
            print("  (Tip: check ../data/InCollege-Output.txt)")
            failed += 1

    os.chdir(start_cwd)
    print(f"\nSummary: {passed} passed, {failed} failed, {len(tests)} total")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser(description="InCollege test runner (Python)")
    p.add_argument("test_file", nargs="?", default="tests/InCollege-Test.txt", help="Path to test file")
    p.add_argument("--export", action="store_true", help="Export per-test input/output under ./export/{input,output}")
    args = p.parse_args()
    # If user specifies '*' (must be quoted to avoid shell globbing), run all test files under tests/
    if args.test_file == "*":
        test_dir = Path("tests")
        all_tests = sorted(str(p) for p in test_dir.glob("*.txt"))
        if not all_tests:
            print("No test files found in ./tests")
            raise SystemExit(1)
        overall_rc = 0
        for tf in all_tests:
            rc = run_tests(tf, export=args.export)
            if rc != 0:
                overall_rc = 1
        raise SystemExit(overall_rc)
    else:
        raise SystemExit(run_tests(args.test_file, export=args.export))
