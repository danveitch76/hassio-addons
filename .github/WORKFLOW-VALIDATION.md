# Actual add-on build validation

Work item: danveitch76/danos-engineering#22, ESTATE-22-HASSIO. Repository issues remain disabled.

The former builder skipped image jobs on workflow-only changes, giving misleading green validation. This repair adopts the reviewed composite-builder pattern from central-rsyslog-logger#14, retaining pialert, sambanas and speedtest and the existing aarch64 scope.

A null-delimited git diff selects affected code. Workflow, selector and shared build changes validate all add-ons; nine regression tests cover selection, filenames and production-publication boundaries. Add-on metadata is read as raw scalars to avoid literal JSON quotes in Docker references. Arm64 emulation is enabled and build caches are separated per add-on.

Pull requests never publish or sign. Workflow-only changes also validate without publication after merge. Only a main push that changes an add-on's non-Markdown content selects that add-on for existing production publication/signing. Unknown base ranges do not authorise publication.

Hosted lint and actual image-build jobs must pass before merge. No product code, add-on version or architecture change is included. Record residual defects rather than suppressing a failed image build. No release is published solely to complete an audit.

This change is compliant with Programme Baseline v1.0.0.
