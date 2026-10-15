// ==UserScript==
// @name         Chat UI Scroll & Blur Fix
// @match        https://gemini.google.com/*
// @match        https://claude.ai/*
// @run-at       document-idle
// @qute-js-world main
// ==/UserScript==

(() => {
  'use strict';
  const STEP = 60; // px por flecha; Chromium usa ~40

  const deepActive = () => {
    let el = document.activeElement;
    while (el && el.shadowRoot && el.shadowRoot.activeElement) el = el.shadowRoot.activeElement;
    return el;
  };

  const isEditable = (el) => {
    if (!el || el.nodeType !== 1) return false;
    if (el.isContentEditable) return true;
    const t = el.tagName;
    if (t === 'TEXTAREA' || t === 'SELECT') return true;
    if (t === 'INPUT') return !['button','checkbox','radio','submit','reset','file','image'].includes(el.type);
    return el.getAttribute('role') === 'textbox';
  };

  const canScroll = (el) => {
    if (el.nodeType !== 1) return false;
    const s = getComputedStyle(el);
    return /(auto|scroll)/.test(s.overflowY) &&
           el.clientHeight > 0 && el.clientWidth > 0 &&
           el.scrollHeight > el.clientHeight + 1;
  };

  const walk = (root, out) => {
    for (const el of root.querySelectorAll('*')) {
      if (el.shadowRoot) walk(el.shadowRoot, out);
      if (canScroll(el)) out.push(el);
    }
  };

  let cached = null;
  const findScroller = () => {
    // Si la ventana misma hace scroll, el comportamiento nativo ya sirve
    const de = document.scrollingElement;
    if (de && de.scrollHeight > de.clientHeight + 1) return null;

    if (cached && cached.isConnected && canScroll(cached)) return cached;

    const found = [];
    walk(document, found);
    cached = found
      .filter((el) => !isEditable(el))
      .sort((a, b) => b.clientHeight * b.clientWidth - a.clientHeight * a.clientWidth)[0] || null;
    return cached;
  };

  const scrollableAncestor = (n) => {
    while (n) {
      if (canScroll(n)) return n;
      n = n.parentNode || n.host; // sube también a través de shadow roots
    }
    return null;
  };

  const release = () => {
    const el = deepActive();
    if (el && el !== document.body) el.blur?.();
    getSelection()?.removeAllRanges();
  };

  // API para jseval; devuelven true si manejaron la acción
  window.__quteFix = {
    blur: () => { release(); return true; },
    scroller: findScroller,
    top:    () => { const s = findScroller(); if (!s) return false; s.scrollTo({ top: 0 }); return true; },
    bottom: () => { const s = findScroller(); if (!s) return false; s.scrollTo({ top: s.scrollHeight }); return true; },
  };

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (isEditable(deepActive())) release();
      return; // sin stopPropagation
    }
    if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
    if (e.ctrlKey || e.altKey || e.metaKey || e.shiftKey) return;
    if (isEditable(deepActive())) return;

    const sc = findScroller();
    if (!sc) return;

    // Si el foco está dentro de otro scroller (menú, barra lateral), deja el nativo
    const own = scrollableAncestor(e.composedPath()[0]);
    if (own && own !== sc) return;

    sc.scrollBy({ top: e.key === 'ArrowDown' ? STEP : -STEP, behavior: 'instant' });
    e.preventDefault();
    e.stopImmediatePropagation();
  }, true);
})();
