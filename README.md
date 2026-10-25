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
preserved synthetic content/copy IDs, while small-widget opening was unverified.
Subsequent navigation failures remain in the run history. CI success can include
skipped host checks and must not be interpreted as visual acceptance.

App matrix: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40200935808
Host evidence: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40201972827
PNG attachments are emitted to public run logs as synthetic-image base64 chunks.
There are no original media/brand images in these logs. This is a public fixture
test harness, not a way to privately transfer production screenshots.

Windows CLI: `gh workflow run ios-preflight.yml --repo HEXAGON-IST/nyammoa-widget-probe`
Then `gh run list --repo HEXAGON-IST/nyammoa-widget-probe`.

`ios-matrix.yml` accepts comma-separated profile IDs and a runner allowlist.
`ios-inventory.yml` reports the xcode-27 image's actual SDK/runtime support.
`ios-host.yml` uses XCUITest to navigate actual SpringBoard/notification hosts.
