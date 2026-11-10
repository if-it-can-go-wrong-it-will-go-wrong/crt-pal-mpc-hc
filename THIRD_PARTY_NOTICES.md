# Third-party notices

Reviewed on 2026-11-10. This review covers the files distributed in this repository and the optional playback components described in the README. The separately installed player and renderers have their own dependency notices.

## License scope

`CRT PAL - MPC-HC.hlsl` and the project-authored documentation are provided under **GPL-3.0-only**. The complete license is in [LICENSE](LICENSE). Redistributors must follow its requirements for attribution, modification notices, licensing, and corresponding source when distributing compiled versions.

## Reused code

The screen geometry adapts `Warp_koko` from Koko-AIO by **Antonio Orefice (kokoko3k)**. CRT PAL simplifies that mapping mathematically and implements the MPC-HC shader interface, video-specific bezel, adaptive scanlines, horizontal spread, glow, and tone adjustments. The modified shader is dated 2026-11-10.

The reviewed upstream revision is `c2f3c5b0ce8c5e7e3ed9d885a924f85712cb38a0` in Libretro's shader repository. Its Koko-AIO license is GNU GPL version 3. The full LICENSE shipped here was compared with that upstream text and matches after line-ending normalization.

- [Koko-AIO project](https://github.com/kokoko3k/koko-aio-slang)
- [Adapted geometry in the reviewed source](https://github.com/libretro/slang-shaders/blob/c2f3c5b0ce8c5e7e3ed9d885a924f85712cb38a0/bezel/koko-aio/shaders-ng/includes/functions.include.slang#L837)
- [Upstream license at the reviewed revision](https://github.com/libretro/slang-shaders/blob/c2f3c5b0ce8c5e7e3ed9d885a924f85712cb38a0/bezel/koko-aio/LICENSE)

## Separately installed playback components

| Component | Reviewed license | How it is used |
| --- | --- | --- |
| Adaptive sharpen, by bacondither, copyright 2015 | BSD-2-Clause, as stated in the installed shader's header | Optional shader placed before CRT PAL, also used in the example screenshots. Its source is supplied by MPC-HC separately. |
| MPC-HC, including EVR Custom Presenter and Sync Renderer | GPL version 3 or later in the reviewed core source notices | Host application and alternative output paths. Player binaries and source are supplied separately. |
| MPC Video Renderer | GPL version 3 or later in the reviewed source notices | Output renderer used during development. Its binaries and source are supplied separately. |
| madVR, by Mathias Rauen | Proprietary software license agreement | Optional output renderer. Its installed `license.txt` governs use and redistribution, including bundling. Its binaries are supplied separately. |
| Microsoft Direct3D, HLSL compiler, and Windows SDK | Microsoft's applicable platform and SDK terms | Runtime interface and development tools. Microsoft binaries and SDK files are supplied separately. |

The installed Adaptive sharpen file was reviewed at version 2015-06-25. Its notice requires preservation of the copyright, conditions, and disclaimer when redistributing source, and reproduction of those notices with binary distributions. A distributor who adds it to a CRT PAL package must include those notices.

- [Adaptive sharpen source and BSD notice in MPC-HC](https://github.com/clsid2/mpc-hc/blob/develop/src/mpc-hc/res/shaders/dx9/Adaptive%20sharpen.hlsl)
- [MPC-HC license](https://github.com/clsid2/mpc-hc/blob/develop/COPYING.txt)
- [MPC-HC core source notice](https://github.com/clsid2/mpc-hc/blob/develop/src/mpc-hc/MainFrm.cpp)
- [MPC Video Renderer license](https://github.com/Aleksoid1978/VideoRenderer/blob/master/LICENSE.txt)
- [MPC Video Renderer source notice](https://github.com/Aleksoid1978/VideoRenderer/blob/master/Source/DX9VideoProcessor.cpp)

## Example screenshots

These PNGs are captures of paused playback in MPC-HC with madVR. Each pair uses the same frame and output size. `no-shaders` disables the post-resize shader chain; `crt-pal` enables Adaptive sharpen followed by CRT PAL. The player interface and exterior pillarboxing were cropped identically. No source video or audio is distributed here. The shader's GPL license does not apply to the underlying films.

### Night on the Galactic Railroad (1985)

Files: `screenshots/galactic-*.png`.

Source: **「銀河鉄道の夜」Blu-ray発売CM**, published by **KADOKAWAanime** on 24 April 2014. This is a short promotional trailer containing footage from the 1985 Japanese animated film by Group TAC, directed by Gisaburō Sugii.

- [Original official trailer](https://www.youtube.com/watch?v=SuQMyhy5edM)
- [Archived original license declaration, 17 August 2019](https://web.archive.org/web/20190817020304/https://www.youtube.com/watch?v=SuQMyhy5edM)
- [Video copy and file record on Wikimedia Commons](https://commons.wikimedia.org/wiki/File:%E3%80%8C%E9%8A%80%E6%B2%B3%E9%89%84%E9%81%93%E3%81%AE%E5%A4%9C%E3%80%8DBlu-ray%E7%99%BA%E5%A3%B2CM.webm)
- [Creative Commons Attribution 3.0 Unported](https://creativecommons.org/licenses/by/3.0/) · [Legal code](https://creativecommons.org/licenses/by/3.0/legalcode)

Attribution: **KADOKAWAanime**. Original copyright notice: **©朝日新聞社／テレビ朝日／KADOKAWA／アスミック・エース** (Asahi Shimbun / TV Asahi / KADOKAWA / Asmik Ace).

The archived official YouTube page was checked directly and states “Creative Commons Attribution license (reuse allowed).” Wikimedia Commons identifies that historical grant as CC BY 3.0 and notes that its community license review is still pending. The historical grant is the basis used here; the full film and unrelated footage are not claimed to be freely licensed.

Changes: still frames extracted through playback, scaled to the display, and cropped to remove the player interface. The right-hand images additionally apply Adaptive sharpen and CRT PAL, including curvature, scanlines, glow, and color processing. These example PNGs and project contributions to them are distributed under **CC BY 3.0**. No endorsement by the original creators or publishers is implied.

### Doomsday Machine (1972)

Files: `screenshots/doomsday-*.png`.

Source: *Doomsday Machine* (1972), credited in the source file record to **Herbert J. Leder**.

- [Wikimedia Commons source and rights statement](https://commons.wikimedia.org/wiki/File:Doomsday_Machine_(1972)_by_Herbert_J._Leder.webm)
- [Reviewed file record](https://commons.wikimedia.org/w/index.php?title=File:Doomsday_Machine_(1972)_by_Herbert_J._Leder.webm&oldid=1173414705)

Wikimedia Commons identifies this film as **public domain in the United States**, on the basis of publication there between 1931 and 1977 without a copyright notice. This is a territorial public-domain claim, not a worldwide Creative Commons license or a grant from a current rights holder. The source record warns that copyright can remain in jurisdictions that do not apply the rule of the shorter term to US works. Reusers must assess the status applicable to their location and use.

Changes: live-action interior frames captured through playback, scaled to the display, and cropped identically. The right-hand images additionally apply Adaptive sharpen and CRT PAL. Any copyright in the project's own screenshot modifications is offered under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/); that offer grants no rights in underlying material where it remains protected.
