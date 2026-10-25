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
