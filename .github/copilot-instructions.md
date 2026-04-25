# GpProfile Copilot Instructions

Use these instructions for all coding tasks in this repository.

## Project Intent
- GpProfile is a Delphi source-instrumenting profiler.
- Core workflow: parse Delphi projects, inject profiling calls, execute profiled app, load and analyze PRF output.

## Architecture Corner Points

### Runtime Include Layer
- Path: include/
- Critical units:
  - include/GpProf.pas
  - include/gpprofCommon.pas
  - include/gpprofh.pas
- Requirements:
  - Keep runtime overhead minimal.
  - Preserve backward compatibility of instrumentation API.
  - Treat include/ as production runtime code used by instrumented applications.

### Parser and Instrumentation Layer
- Path: source/model/sourceCodeAnalysis/
- Critical areas:
  - parser API/orchestration (gpParser*.pas)
  - unit/procedure selection logic
  - source rewriting (gpParser.TextReplacer.pas)
  - Delphi project readers (gpProf.DProjReader.pas and related files)
- Requirements:
  - Preserve source formatting behavior.
  - Maintain conditional-define correctness across targets.
  - Keep instrumentation insertion/removal deterministic.

### Result Parser and Analysis Model
- Path: source/model/profilingResultParser/
- Critical units:
  - gppresults.pas
  - gppResults.types.pas
  - gppResults.procs.pas
  - gppResults.callGraph.pas
  - gppResult.measurePointRegistry.pas
- Requirements:
  - Keep PRF reader/writer compatibility stable.
  - Preserve identifier/thread/timing consistency used by analysis views.

### UI Workflow Layer
- Path: source/ui/
- Critical units:
  - gppMain.pas
  - gppmain.FrameInstrumentation.pas
  - gppmain.FramePerformanceAnalysis.pas
  - gppmain.FrameMemoryAnalysis.pas
- Requirements:
  - Keep business logic in model units where possible.
  - Avoid embedding parser/result logic directly in forms and frames.

## Build and Test Boundaries
- Main app entry: source/gpprof.dpr
- Test app entry: tests/GPProfTester.dpr
- Build notes: buildSources.md
- Treat DCU/, BIN/, bin64/, and versioned snapshot folders as outputs/snapshots, not primary edit targets.

## Safe Change Rules
- Prefer edits in source/ and include/.
- Keep generated instrumentation pairs balanced:
  - ProfilerEnterProc(<id>) and matching ProfilerExitProc(<id>) in finally blocks.
- For runtime output format or placeholder changes, verify both sides:
  - include/ writer behavior
  - source/model/profilingResultParser/ reader behavior
- Keep changes scoped and avoid unrelated refactors.

## Testing Guidance
- Existing regression-style tests live in tests/:
  - tests/testUnit.pas
  - tests/testThreads.pas
  - tests/testMultiDefines.pas
- Add focused tests near related scenarios.
- Prefer explicit test names that describe parser/runtime behavior covered.

## Non-Goals
- Do not modify release snapshot folders unless explicitly requested.
- Do not modify CHM/help binaries during normal code tasks.
