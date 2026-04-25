# GpProfile Repository Instructions

## Purpose
- GpProfile is a Delphi source-instrumenting profiler.
- The tool parses Delphi projects, injects profiling calls into selected procedures, and analyzes generated PRF data.

## Code Corner Points

### 1) Runtime Include Layer (must stay lightweight)
- Path: include/
- Main units:
  - GpProf.pas: runtime API used by instrumented code (ProfilerEnterProc, ProfilerExitProc, thread naming, measure points).
  - gpprofCommon.pas: runtime helper logic, especially PRF filename placeholder resolution.
  - gpprofh.pas: shared runtime constants/types used by writer and reader sides.
- Key rule: keep include/ backward compatible and low overhead because it is linked into profiled applications.

### 2) Source Parsing and Instrumentation Layer
- Path: source/model/sourceCodeAnalysis/
- Main units:
  - gpParser.pas and gpParser.API.pas: parser orchestration and API surface.
  - gpParser.Units*.pas, gpParser.Procs.pas, gpParser.Selections.pas: unit/procedure discovery and selection handling.
  - gpParser.TextReplacer.pas: source rewrite primitives for adding/removing instrumentation calls.
  - gpProf.DProjReader.pas and related project readers: project/options ingestion.
- Key rule: preserve source formatting and conditional-define behavior; multi-target parsing support is a core feature.

### 3) Profiling Result Parser and Analysis Model
- Path: source/model/profilingResultParser/
- Main units:
  - gppresults.pas and gppResults.types.pas: PRF result loading and core data structures.
  - gppResults.procs.pas and gppResults.callGraph.pas: procedure statistics and caller/callee graph logic.
  - gppResult.measurePointRegistry.pas: measure point tracking and aggregation.
- Key rule: parser correctness is critical; analysis views depend on stable identifiers and timings.

### 4) UI and Workflow Layer
- Path: source/ui/
- Main units:
  - gppMain.pas: main shell and workflow wiring.
  - gppmain.FrameInstrumentation.pas: selection/instrumentation workflow.
  - gppmain.FramePerformanceAnalysis.pas and gppmain.FrameMemoryAnalysis.pas: analysis screens.
- Key rule: UI code should delegate core logic to model units; avoid business logic drift into forms/frames.

### 5) App Entry and Build Boundaries
- App project entry: source/gpprof.dpr
- Test project entry: tests/GPProfTester.dpr
- Build notes: see buildSources.md (Delphi toolchain and dependencies such as VirtualTreeView/SynEdit/GPComponents).
- Key rule: do not treat compiled output folders (DCU/, BIN/, bin64/, versioned release folders) as source-of-truth.

## Editing Guidance
- Prefer changes in source/ and include/ over generated/binary artifacts.
- Keep instrumentation markers and generated call pairs balanced:
  - ProfilerEnterProc(<id>) with matching ProfilerExitProc(<id>) in finally blocks.
- For runtime/output changes, verify both ends:
  - include/ writer behavior and source/model/profilingResultParser/ reader behavior.
- For parser changes, validate with edge cases already represented in tests (threads, nested types, multi-define blocks).

## Testing Guidance
- Existing tests are Delphi console tests under tests/.
- Important files:
  - tests/testUnit.pas
  - tests/testThreads.pas
  - tests/testMultiDefines.pas
- Add focused tests near similar scenarios and keep test names explicit about parser/runtime behavior being validated.

## Non-Goals
- Do not edit legacy release snapshot folders unless explicitly requested.
- Do not edit CHM/help binaries as part of normal code changes.
