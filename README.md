# Approved icon and Moa OS-host observation

The user approved public use of the selected bowl-Moa app icon and Moa A/B
poses on 2026-10-26. These three PNG files match the existing approved exports.
Other character images and the media slot remain geometric fixtures. The app
picker exposes Moa only. No X/YouTube original screenshot, thumbnail, video,
account data, or whole-product source is published. The approved Korean copy
and X01 destination identifier are used to test text and routing only.

This is S2 verification, not a released app or acceptance of all four OS surfaces.
Original-media layout review stays local. Do not interpret the geometric media
slot as an actual post or as proof of original-media fit/readability.

The manual ios-host.yml workflow defaults to account-free local Simulator
ad-hoc signing. It uses the public-only guard, standard macos-15, existing
SDK/runtime, 20-minute limit, and no artifact/cache upload. PNG captures in
public logs may show the approved icon and Moa. No secret or account changes.

Run: gh workflow run ios-host.yml --repo HEXAGON-IST/nyammoa-widget-probe -f signing=adhoc-local
Approved-brand home observation: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40214621861
Its actual screenshots show the approved launcher icon and Moa in small and
medium widgets. Both image-area links preserved the content/copy IDs. Its
notification-content automatic result was an offscreen accessibility false
positive: screenshots showed a notification count and wallpaper customization.
The original logs/captures remain unchanged; visual review corrects that claim.

Notification-only observation: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40216279175
After revealing the notification list and requiring hittable in-screen text,
the collapsed card visibly showed the approved app icon and copy. Expansion
still did not occur; the custom-character check was skipped. Motion was not
tested. This follow-up did not rerun the home-widget tests. The preceding
40215886985 attempt timed out listing runtimes before build/tests.

Use `-f tests=notifications` for the notification-only scope; the default is all.
Do not treat CI success with skipped checks as all-surface acceptance.
Earlier signed geometric-content observation: https://github.com/HEXAGON-IST/nyammoa-widget-probe/actions/runs/40211183811

Other manual workflows are retained as historical harnesses. Do not infer their
default signing mode or all-model host acceptance from this single-host run.

Sage home revision (2026-10-26): home background uses the approved icon's
RGB(220,231,206), #DCE7CE. Native framing excludes transparent padding without
editing the original PNGs. Small home uses 72pt, medium uses 88pt; notification
source/layout/background remains unchanged.

Run 40218804171 observed the medium home and destination, but failed the small
test due to keyboard focus. Refocusing Search Widgets repaired that harness
issue. Run 40219967727 passed automatically but visual inspection found small
home copy truncated. Small-only run 40220928347, tested commit
7850f83a20ef51ff89a9e11baf61fde1a53c81c0, passed in 10m18s. Direct screenshot
inspection showed the full Korean copy with no ellipsis and a larger Moa.
This is one iPhone 16/iOS18.5 observation, not all-device or motion acceptance.
Use `-f tests=small` for the small-only scope. Geometric media remains a fixture.

Interaction follow-up: tests=interactions taps the visible Moa button twice, requires accessible pose change/restoration without app entry, then verifies the media destination. Captures require visual review. No continuous-motion or all-device claim. Visual size/color and all three approved PNGs are unchanged.
