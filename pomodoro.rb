#!/usr/bin/env ruby
# Pomodoro Timer - Ruby Script
# Membuat file HTML indah dan membukanya di browser

require 'tempfile'
require 'rbconfig'

HTML_CONTENT = <<~HTML
<!doctype html>
<html lang="id">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Pomodoro Timer</title>
    <link
      href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Bebas+Neue&family=DM+Sans:wght@300;400;500&display=swap"
      rel="stylesheet"
    />
    <style>
      :root {
        --bg: #0a0a0f;
        --surface: #12121a;
        --card: #1a1a26;
        --border: #2a2a3f;
        --tomato: #ff4d4d;
        --tomato-glow: rgba(255, 77, 77, 0.3);
        --break: #4dffb8;
        --break-glow: rgba(77, 255, 184, 0.3);
        --muted: #666688;
        --text: #eeeeff;
        --accent: #ff4d4d;
        --accent-glow: rgba(255, 77, 77, 0.3);
      }
      *,
      *::before,
      *::after {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
      }

      body {
        background: var(--bg);
        color: var(--text);
        font-family: "DM Sans", sans-serif;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        position: relative;
      }

      /* Ambient background */
      body::before {
        content: "";
        position: fixed;
        width: 600px;
        height: 600px;
        border-radius: 50%;
        background: radial-gradient(
          circle,
          var(--accent-glow) 0%,
          transparent 70%
        );
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        pointer-events: none;
        transition: background 0.8s ease;
        z-index: 0;
      }

      body.break-mode::before {
        background: radial-gradient(
          circle,
          var(--break-glow) 0%,
          transparent 70%
        );
      }

      /* Noise texture overlay */
      body::after {
        content: "";
        position: fixed;
        inset: 0;
        background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.04'/%3E%3C/svg%3E");
        pointer-events: none;
        z-index: 0;
        opacity: 0.5;
      }

      .container {
        position: relative;
        z-index: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 32px;
        padding: 24px;
      }

      /* Header */
      .header {
        text-align: center;
      }

      .logo {
        font-family: "Bebas Neue", sans-serif;
        font-size: 14px;
        letter-spacing: 6px;
        color: var(--muted);
        margin-bottom: 4px;
      }

      .title {
        font-family: "Bebas Neue", sans-serif;
        font-size: clamp(36px, 6vw, 52px);
        letter-spacing: 4px;
        color: var(--text);
        line-height: 1;
      }

      /* Mode tabs */
      .tabs {
        display: flex;
        gap: 2px;
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 12px;
        padding: 4px;
      }

      .tab {
        font-family: "DM Sans", sans-serif;
        font-size: 13px;
        font-weight: 500;
        padding: 8px 20px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        background: transparent;
        color: var(--muted);
        letter-spacing: 0.5px;
        transition: all 0.25s ease;
      }

      .tab.active {
        background: var(--accent);
        color: #fff;
        box-shadow: 0 0 20px var(--accent-glow);
      }

      .tab:not(.active):hover {
        color: var(--text);
      }

      /* Timer Card */
      .timer-card {
        background: var(--card);
        border: 1px solid var(--border);
        border-radius: 28px;
        padding: 52px 64px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 40px;
        position: relative;
        overflow: hidden;
        box-shadow:
          0 40px 80px rgba(0, 0, 0, 0.5),
          inset 0 1px 0 rgba(255, 255, 255, 0.05);
        min-width: 360px;
      }

      /* SVG ring progress */
      .ring-wrapper {
        position: relative;
        width: 220px;
        height: 220px;
      }

      .ring-svg {
        width: 220px;
        height: 220px;
        transform: rotate(-90deg);
      }

      .ring-bg {
        fill: none;
        stroke: var(--border);
        stroke-width: 6;
      }

      .ring-progress {
        fill: none;
        stroke: var(--accent);
        stroke-width: 6;
        stroke-linecap: round;
        stroke-dasharray: 628;
        stroke-dashoffset: 0;
        filter: drop-shadow(0 0 8px var(--accent-glow));
        transition:
          stroke-dashoffset 1s linear,
          stroke 0.8s ease,
          filter 0.8s ease;
      }

      .break-mode .ring-progress {
        stroke: var(--break);
        filter: drop-shadow(0 0 8px var(--break-glow));
      }

      .timer-center {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
      }

      .timer-display {
        font-family: "Space Mono", monospace;
        font-size: 56px;
        font-weight: 700;
        letter-spacing: -2px;
        color: var(--text);
        line-height: 1;
        transition: color 0.5s ease;
      }

      .timer-label {
        font-size: 11px;
        font-weight: 500;
        letter-spacing: 3px;
        color: var(--muted);
        text-transform: uppercase;
        margin-top: 6px;
      }

      /* Controls */
      .controls {
        display: flex;
        gap: 16px;
        align-items: center;
      }

      .btn-main {
        font-family: "Bebas Neue", sans-serif;
        font-size: 22px;
        letter-spacing: 3px;
        padding: 14px 52px;
        border-radius: 14px;
        border: none;
        cursor: pointer;
        background: var(--accent);
        color: #fff;
        box-shadow:
          0 8px 32px var(--accent-glow),
          0 0 0 0 var(--accent-glow);
        transition: all 0.25s ease;
        position: relative;
        overflow: hidden;
      }

      .btn-main::after {
        content: "";
        position: absolute;
        inset: 0;
        background: rgba(255, 255, 255, 0.1);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .btn-main:hover::after {
        opacity: 1;
      }
      .btn-main:active {
        transform: scale(0.97);
      }

      .break-mode .btn-main {
        background: var(--break);
        color: #0a0a0f;
        box-shadow: 0 8px 32px var(--break-glow);
      }

      .btn-icon {
        width: 46px;
        height: 46px;
        border-radius: 12px;
        border: 1px solid var(--border);
        background: var(--surface);
        color: var(--muted);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        font-size: 18px;
      }

      .btn-icon:hover {
        color: var(--text);
        border-color: var(--text);
        background: var(--card);
      }

      /* Stats row */
      .stats {
        display: flex;
        gap: 32px;
      }

      .stat {
        text-align: center;
      }

      .stat-num {
        font-family: "Space Mono", monospace;
        font-size: 28px;
        font-weight: 700;
        color: var(--accent);
        transition: color 0.8s ease;
      }

      .break-mode .stat-num {
        color: var(--break);
      }

      .stat-label {
        font-size: 10px;
        letter-spacing: 2px;
        color: var(--muted);
        text-transform: uppercase;
      }

      /* Session dots */
      .session-dots {
        display: flex;
        gap: 8px;
      }

      .dot {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: var(--border);
        transition: all 0.4s ease;
      }

      .dot.done {
        background: var(--accent);
        box-shadow: 0 0 10px var(--accent-glow);
      }

      .break-mode .dot.done {
        background: var(--break);
        box-shadow: 0 0 10px var(--break-glow);
      }

      /* Notification toast */
      .toast {
        position: fixed;
        bottom: 32px;
        left: 50%;
        transform: translateX(-50%) translateY(100px);
        background: var(--card);
        border: 1px solid var(--border);
        border-radius: 14px;
        padding: 14px 28px;
        font-size: 14px;
        font-weight: 500;
        color: var(--text);
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        z-index: 100;
        white-space: nowrap;
      }

      .toast.show {
        transform: translateX(-50%) translateY(0);
      }

      /* Pulsing animation when running */
      @keyframes pulse-ring {
        0%,
        100% {
          opacity: 1;
        }
        50% {
          opacity: 0.7;
        }
      }

      .running .ring-progress {
        animation: pulse-ring 4s ease-in-out infinite;
      }

      /* Scanning line effect */
      .timer-card::before {
        content: "";
        position: absolute;
        top: -100%;
        left: 0;
        right: 0;
        height: 40%;
        background: linear-gradient(
          to bottom,
          transparent,
          rgba(255, 255, 255, 0.015),
          transparent
        );
        animation: scan 6s linear infinite;
        pointer-events: none;
      }

      @keyframes scan {
        0% {
          top: -40%;
        }
        100% {
          top: 140%;
        }
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <div class="logo">FOCUS &middot; FLOW &middot; REST</div>
        <div class="title">Pomodoro</div>
      </div>

      <div class="tabs">
        <button class="tab active" onclick="setMode('focus')">Fokus</button>
        <button class="tab" onclick="setMode('short')">Istirahat Pendek</button>
        <button class="tab" onclick="setMode('long')">Istirahat Panjang</button>
      </div>

      <div class="timer-card" id="timerCard">
        <div class="ring-wrapper">
          <svg class="ring-svg" viewBox="0 0 220 220">
            <circle class="ring-bg" cx="110" cy="110" r="100" />
            <circle
              class="ring-progress"
              id="ringProgress"
              cx="110"
              cy="110"
              r="100"
            />
          </svg>
          <div class="timer-center">
            <div class="timer-display" id="timerDisplay">25:00</div>
            <div class="timer-label" id="timerLabel">SESI FOKUS</div>
          </div>
        </div>

        <div class="session-dots" id="sessionDots">
          <div class="dot" id="d1"></div>
          <div class="dot" id="d2"></div>
          <div class="dot" id="d3"></div>
          <div class="dot" id="d4"></div>
        </div>

        <div class="controls">
          <button class="btn-icon" onclick="reset()" title="Reset">
            &#x21BA;
          </button>
          <button class="btn-main" id="startBtn" onclick="toggle()">
            MULAI
          </button>
          <button class="btn-icon" onclick="skip()" title="Skip">
            &#x23ED;
          </button>
        </div>

        <div class="stats">
          <div class="stat">
            <div class="stat-num" id="sessCount">0</div>
            <div class="stat-label">Sesi</div>
          </div>
          <div class="stat">
            <div class="stat-num" id="focusMin">0</div>
            <div class="stat-label">Menit Fokus</div>
          </div>
          <div class="stat">
            <div class="stat-num" id="breakMin">0</div>
            <div class="stat-label">Menit Istirahat</div>
          </div>
        </div>
      </div>
    </div>

    <div class="toast" id="toast"></div>

    <script>
      const MODES = {
        focus: { label: 'SESI FOKUS', minutes: 25 },
        short: { label: 'ISTIRAHAT PENDEK', minutes: 5 },
        long:  { label: 'ISTIRAHAT PANJANG', minutes: 15 },
      };

      let mode = 'focus';
      let totalSeconds = 25 * 60;
      let remaining = totalSeconds;
      let running = false;
      let interval = null;
      let completedSessions = 0;
      let totalFocusSeconds = 0;
      let totalBreakSeconds = 0;

      const display = document.getElementById('timerDisplay');
      const label = document.getElementById('timerLabel');
      const startBtn = document.getElementById('startBtn');
      const ring = document.getElementById('ringProgress');
      const card = document.getElementById('timerCard');
      const body = document.body;
      const CIRC = 628;

function fmt(s) {
  const m = Math.floor(s / 60);
  const sec = s % 60;
  return `\${String(m).padStart(2, '0')}:\${String(sec).padStart(2, '0')}`;
}

      function updateRing() {
        const pct = remaining / totalSeconds;
        ring.style.strokeDashoffset = CIRC * (1 - pct);
      }

      function setMode(m, auto = false) {
        if (running && !auto) { reset(); }
        mode = m;
        const cfg = MODES[m];
        totalSeconds = cfg.minutes * 60;
        remaining = totalSeconds;
        label.textContent = cfg.label;
        display.textContent = fmt(remaining);
        updateRing();

        // tabs
        document.querySelectorAll('.tab').forEach((t, i) => {
          t.classList.toggle('active', ['focus','short','long'][i] === m);
        });

        // break mode styling
        const isBreak = m !== 'focus';
        body.classList.toggle('break-mode', isBreak);
      }

      function toggle() {
        if (running) {
          pause();
        } else {
          start();
        }
      }

      function start() {
        running = true;
        startBtn.textContent = 'JEDA';
        card.classList.add('running');
        interval = setInterval(tick, 1000);
      }

      function pause() {
        running = false;
        startBtn.textContent = 'LANJUT';
        card.classList.remove('running');
        clearInterval(interval);
      }

      function reset() {
        pause();
        startBtn.textContent = 'MULAI';
        remaining = totalSeconds;
        display.textContent = fmt(remaining);
        updateRing();
      }

      function skip() {
        clearInterval(interval);
        running = false;
        card.classList.remove('running');
        complete();
      }

      function tick() {
        remaining--;
        // Accumulate time
        if (mode === 'focus') totalFocusSeconds++;
        else totalBreakSeconds++;

        display.textContent = fmt(remaining);
        updateRing();

        // Update stat displays
        document.getElementById('focusMin').textContent = Math.floor(totalFocusSeconds / 60);
        document.getElementById('breakMin').textContent = Math.floor(totalBreakSeconds / 60);

        if (remaining <= 0) {
          clearInterval(interval);
          running = false;
          card.classList.remove('running');
          complete();
        }
      }

      function complete() {
        if (mode === 'focus') {
          completedSessions++;
          document.getElementById('sessCount').textContent = completedSessions;
          updateDots();
          showToast('🍅 Sesi selesai! Waktunya istirahat.');
          // Auto switch to break
          setTimeout(() => {
            setMode(completedSessions % 4 === 0 ? 'long' : 'short', true);
            startBtn.textContent = 'MULAI';
          }, 600);
        } else {
          showToast('⚡ Istirahat selesai! Ayo fokus lagi.');
          setTimeout(() => {
            setMode('focus', true);
            startBtn.textContent = 'MULAI';
          }, 600);
        }
      }

      function updateDots() {
        for (let i = 1; i <= 4; i++) {
          document.getElementById('d' + i).classList.toggle('done', i <= (completedSessions % 4 || (completedSessions > 0 && completedSessions % 4 === 0 ? 4 : 0)));
        }
      }

      function showToast(msg) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 3500);

        // Browser notification
        if (Notification.permission === 'granted') {
          new Notification('Pomodoro Timer', { body: msg, icon: '' });
        }
      }

      // Request notification permission
      if (Notification.permission === 'default') {
        Notification.requestPermission();
      }

      // Init ring
      updateRing();
    </script>
  </body>
</html>
HTML

# Determine OS and open browser
def open_browser(file_path)
  url = "file://#{file_path}"
  
  case RbConfig::CONFIG['host_os']
  when /mswin|mingw|cygwin/
    system("start #{url}")
  when /darwin/
    system("open '#{url}'")
  when /linux/
    system("xdg-open '#{url}' 2>/dev/null || sensible-browser '#{url}' 2>/dev/null || google-chrome '#{url}' 2>/dev/null")
  else
    puts "Buka file ini di browser: #{url}"
  end
end

# Save HTML to a temp file (lebih permanen dari Tempfile)
html_path = File.join(Dir.home, 'pomodoro_timer.html')
File.write(html_path, HTML_CONTENT)

puts "╔══════════════════════════════════════╗"
puts "║       🍅 POMODORO TIMER RUBY         ║"
puts "╚══════════════════════════════════════╝"
puts ""
puts "✅ File HTML dibuat di: #{html_path}"
puts "🌐 Membuka browser..."
puts ""
puts "Fitur:"
puts "  • Timer 25 menit fokus, 5/15 menit istirahat"
puts "  • Progress ring animasi"
puts "  • Statistik sesi real-time"
puts "  • Notifikasi browser"
puts "  • UI dark mode modern"
puts ""

open_browser(html_path)

puts "✨ Selamat fokus!"