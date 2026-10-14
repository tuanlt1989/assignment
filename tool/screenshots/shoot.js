// Captures raw store screenshots from the web build's demo scenes.
//   flutter build web --release --no-web-resources-cdn --dart-define=NO_ADS=true
//   (cd build/web && python3 -m http.server 8765) &
//   cd tool/screenshots && npm install && node shoot.js
//   python3 tool/frame_screenshots.py
// Games: ROOT=games SCENES=home,play,play2,play3 node shoot.js
const { chromium } = require('playwright-core');
const fs = require('fs');
const path = require('path');
const ROOT = path.join(__dirname, '../..', process.env.ROOT || '.');
const OUT = path.join(ROOT, 'build/raw_screenshots');
fs.mkdirSync(OUT, { recursive: true });
const CHROME = process.env.CHROME_PATH; // optional; otherwise Playwright's own Chromium
const apps = fs.readdirSync(path.join(ROOT, 'apps')).filter((f) => f.endsWith('.json')).map((f) => f.slice(0, -5));
const scenes = (process.env.SCENES || 'home,practice,exam,result').split(',');
(async () => {
  const browser = await chromium.launch(CHROME ? { executablePath: CHROME } : {});
  for (const app of apps) {
    for (const scene of scenes) {
      const ctx = await browser.newContext({ viewport: { width: 400, height: 760 }, deviceScaleFactor: 2.7 });
      const page = await ctx.newPage();
      await page.goto(`http://127.0.0.1:${process.env.PORT || 8765}/?app=${app}&demo=${scene}`);
      await page.waitForTimeout(4500);
      await page.screenshot({ path: path.join(OUT, `${app}_${scene}.png`) });
      await ctx.close();
      console.log(app, scene);
    }
  }
  await browser.close();
})();
