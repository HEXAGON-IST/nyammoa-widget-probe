# iOS widget host probe

S2 standalone feasibility harness, not a production application.
All PNG files are generated geometric fixtures; no original X/YouTube media,
approved character artwork, secrets, account data, or product governance is included.

Manual Actions only, public repository guard, standard macos-15/xcode-27 runners,
bounded jobs (4/15/20/25 minutes by workflow), no cache/artifact uploads,
no signing accounts or paid services. Existing SDKs and runtimes only.
The iPhone list preserves researched model names. Missing installed device types
are reported unavailable; no SDK/runtime downloads or substituted models.
Compilation and app launch do not establish widget/notification host acceptance.
All 14 iPhone profiles have at least one observed app launch (iOS18.5 or27.0).
This is not a claim that four host surfaces passed on all profiles.
The iPhone16/iOS18.5 host run observed notification extension content;
home widgets still displayed grey placeholders. A medium-widget destination
preserved synthetic content/copy IDs. A later run observed image-area links
for both small and medium widgets, but both still displayed placeholders.
Subsequent navigation failures remain in the run history. CI success can include
skipped host checks and must not be interpreted as visual acceptance.

App matrix: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40200935808
Unsigned baseline: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40207353650
Local-signing observation: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40211183811
The local ad-hoc Simulator signing run displayed synthetic content in both
small and medium home widgets and preserved both destination IDs. Its app and
test-runner signatures report adhoc and no TeamIdentifier. No Apple account,
provisioning profile, paid runner, or SDK download was used.
This is one iPhone16/iOS18.5 observation, not all-model visual acceptance.
Small-widget wrapping needs review; notification expansion was skipped and
character interaction/motion was not tested. Metadata9004 messages remain.
Earlier extension display: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40201972827
Generated metadata: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40208766055
App and widget targets both emit ProbeConfiguration/ReactIntent metadata.
Runtime metadata lookup/helper communication failures remain unresolved.
The latest notification extension navigation was skipped; earlier display
observation is not stable animation acceptance or a latest-run pass.
PNG attachments are emitted to public run logs as synthetic-image base64 chunks.
There are no original media/brand images in these logs. This is a public fixture
test harness, not a way to privately transfer production screenshots.

Windows CLI: `gh workflow run ios-preflight.yml --repo HEXAGON-IST/nyammoa-widget-probe`
Then `gh run list --repo HEXAGON-IST/nyammoa-widget-probe`.

`ios-matrix.yml` accepts comma-separated profile IDs and a runner allowlist.
`ios-inventory.yml` reports the xcode-27 image's actual SDK/runtime support.
`ios-host.yml` uses XCUITest to navigate actual SpringBoard/notification hosts.
It accepts `signing=adhoc-local` for local Simulator signing; `unsigned` remains
the default experimental baseline. Use `-f signing=adhoc-local` explicitly
when reproducing the observed content path. The first local-signing attempt
(40210812715) timed out listing runtimes before build, so it did not test signing.
`ios-metadata.yml` builds and emits fixture AppIntent metadata without UI tests.
