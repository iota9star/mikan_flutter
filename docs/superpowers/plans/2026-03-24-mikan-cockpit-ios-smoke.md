# Mikan Cockpit iOS Smoke Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a minimal debug-safe `flutter_cockpit` integration to the app and run an evidence-backed smoke test on the iOS simulator.

**Architecture:** Keep the integration at the app root only. Add a local path dependency on `flutter_cockpit`, wrap the existing app bootstrap with `FlutterCockpitApp` in debug builds, and register the cockpit navigator observer alongside the app's existing observers. Use host-side `flutter_cockpit_devtools` to launch the simulator session, capture baseline and acceptance artifacts, then validate the resulting bundle.

**Tech Stack:** Flutter 3.38, iOS Simulator, local `flutter_cockpit` package, local `flutter_cockpit_devtools` CLI

---

### Task 1: Add Minimal App-Side Cockpit Bootstrap

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/app/mikan_app.dart`

- [ ] Add a local path dependency on `flutter_cockpit` without disturbing existing user changes in `pubspec.yaml`.
- [ ] Run `flutter pub get` and fix any dependency or Pod resolution issues introduced by the new plugin.
- [ ] Wrap the root app with `FlutterCockpitApp` in debug builds only.
- [ ] Keep cockpit diagnostics controlled by compile-time defines.
- [ ] Add `FlutterCockpit.navigatorObserver` to the existing `MaterialApp.navigatorObservers` list only when cockpit is active.
- [ ] Run `flutter analyze lib/app/bootstrap.dart lib/app/mikan_app.dart` and fix compile issues before continuing.

### Task 2: Launch An iOS Remote Session And Capture Baseline

**Files:**
- Read only: `ios/Runner.xcodeproj`, generated build files, simulator artifacts

- [ ] Confirm the target simulator is booted and reachable.
- [ ] Use local `flutter_cockpit_devtools` to inspect the required CLI flags.
- [ ] Launch a remote session for the iOS simulator against `lib/main.dart`.
- [ ] Query the session and confirm reachability before any acceptance claim.
- [ ] Capture a baseline screenshot and record the session handle path.

### Task 3: Run Smoke Acceptance And Validate Evidence

**Files:**
- Create: task config JSON under `/tmp` or another scratch path
- Read only: generated task bundle artifacts

- [ ] Define a bounded smoke flow that covers app launch and at least the main visible navigation state.
- [ ] Run `run-task` to produce an evidence bundle with screenshot output and recording if available.
- [ ] Run `validate-task` on the bundle before claiming success.
- [ ] Read the bundle summary, `baseline_evidence`, `acceptance_evidence`, and `acceptance_delta`.
- [ ] Classify the result as `completed`, `failed_with_evidence`, `needs_more_work`, or `blocked_by_environment`.

### Task 4: Deliver Verified Outcome

**Files:**
- Read only: generated artifact paths

- [ ] Summarize the verified result using post-run evidence, not command success.
- [ ] Include the primary screenshot path and any recording or keyframe paths if present.
- [ ] Call out any environment blockers or evidence gaps explicitly if the completion gate is not met.
