(function () {
    'use strict';

    var hasLibs = !!(window.gsap && window.ScrollTrigger && window.Lenis);
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    document.addEventListener('DOMContentLoaded', function () {

        // === Toast 提示 ===
        var toastTimer;
        function showToast(msg) {
            var t = document.getElementById('toast');
            if (!t) return;
            t.textContent = msg;
            t.classList.add('show');
            clearTimeout(toastTimer);
            toastTimer = setTimeout(function () { t.classList.remove('show'); }, 2500);
        }
        window.showToast = showToast;

        // === 页脚年份 ===
        var yearEl = document.getElementById('copyYear');
        if (yearEl) yearEl.textContent = String(new Date().getFullYear());

        // === 移动端菜单（含滚动锁定、ESC 关闭、aria 状态） ===
        var menuBtn = document.getElementById('menuBtn');
        var mobileMenu = document.getElementById('mobileMenu');

        if (menuBtn && mobileMenu) {
            var setMenu = function (open) {
                mobileMenu.classList.toggle('open', open);
                mobileMenu.setAttribute('aria-hidden', open ? 'false' : 'true');
                menuBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
                menuBtn.setAttribute('aria-label', open ? '关闭菜单' : '打开菜单');
                menuBtn.innerHTML = open
                    ? '<svg class="ico" aria-hidden="true"><use href="#i-close"/></svg>'
                    : '<svg class="ico" aria-hidden="true"><use href="#i-bars"/></svg>';
                document.body.classList.toggle('menu-open', open);
            };

            menuBtn.addEventListener('click', function () {
                setMenu(!mobileMenu.classList.contains('open'));
            });

            mobileMenu.querySelectorAll('[data-close-mobile]').forEach(function (link) {
                link.addEventListener('click', function () { setMenu(false); });
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape' && mobileMenu.classList.contains('open')) setMenu(false);
            });
        }

        // === 导航栏滚动效果 ===
        var nav = document.getElementById('nav');
        if (nav) {
            var onScroll = function () {
                nav.classList.toggle('scrolled', window.scrollY > 50);
            };
            window.addEventListener('scroll', onScroll, { passive: true });
            onScroll();
        }

        // === 动画初始化（库缺失或用户偏好减少动效时整体跳过） ===
        var useMotion = hasLibs && !reduceMotion;

        if (useMotion) {
            try {
                initPageAnimations();
                initSmoothScroll();
            } catch (err) {
                // 动画失败也不能影响内容可读性：直接把文字复位
                document.documentElement.classList.remove('js');
                document.documentElement.classList.add('anim-failed');
                if (window.console) console.warn('[motion] 初始化失败，已回退为静态显示', err);
            }
        } else {
            document.documentElement.classList.remove('js');
            document.documentElement.classList.add('no-js');
        }

        function initPageAnimations() {
            gsap.registerPlugin(ScrollTrigger);

            // Hero 标题
            gsap.to('.hero-title span', {
                y: 0,
                duration: 1.5,
                ease: 'power4.out'
            });

            // Hero 副标题
            gsap.to('.hero-sub', { opacity: 1, duration: 1, delay: 0.5 });

            // 标题逐字显示
            document.querySelectorAll('.section-heading').forEach(function (el) {
                var text = el.textContent;
                el.textContent = '';
                text.split('').forEach(function (char) {
                    if (char === ' ') {
                        el.appendChild(document.createTextNode(' '));
                    } else {
                        var wrap = document.createElement('span');
                        wrap.className = 'word-wrap';
                        var inner = document.createElement('span');
                        inner.className = 'word-inner';
                        inner.textContent = char;
                        wrap.appendChild(inner);
                        el.appendChild(wrap);
                    }
                });
                gsap.to(el.querySelectorAll('.word-inner'), {
                    y: '0%',
                    duration: 1,
                    ease: 'power3.out',
                    stagger: 0.02,
                    scrollTrigger: { trigger: el, start: 'top 85%', toggleActions: 'play none none reverse' }
                });
            });

            // 项目列表
            gsap.utils.toArray('.project-item').forEach(function (item) {
                gsap.from(item, {
                    opacity: 0,
                    y: 30,
                    duration: 0.8,
                    ease: 'power3.out',
                    scrollTrigger: { trigger: item, start: 'top 90%', toggleActions: 'play none none reverse' }
                });
            });

            // 技能卡片
            gsap.utils.toArray('.skill-card').forEach(function (card) {
                gsap.from(card, {
                    opacity: 0,
                    y: 40,
                    duration: 0.8,
                    ease: 'power3.out',
                    scrollTrigger: { trigger: card, start: 'top 85%', toggleActions: 'play none none reverse' }
                });
            });

            // 个人资料卡与侧栏小部件
            gsap.from('.profile-card', {
                opacity: 0,
                y: 40,
                duration: 1,
                ease: 'power3.out',
                scrollTrigger: { trigger: '.profile-card', start: 'top 85%' }
            });

            gsap.from('.widget-card', {
                opacity: 0,
                y: 30,
                duration: 0.8,
                stagger: 0.2,
                ease: 'power3.out',
                scrollTrigger: { trigger: '.widgets-column', start: 'top 85%' }
            });

            // 页脚 CTA
            gsap.from('.footer-cta', {
                y: 60,
                opacity: 0.5,
                scale: 0.9,
                scrollTrigger: { trigger: '.footer', start: 'top bottom', end: 'bottom bottom', scrub: true }
            });
        }

        function initSmoothScroll() {
            // 只由 gsap.ticker 单一驱动（原版本 raf 循环与 ticker 同时调用 lenis.raf，导致重复推进）
            var lenis = new Lenis({
                duration: 1.2,
                easing: function (t) { return Math.min(1, 1.001 - Math.pow(2, -10 * t)); },
                smoothWheel: true
            });

            lenis.on('scroll', ScrollTrigger.update);
            gsap.ticker.add(function (time) { lenis.raf(time * 1000); });
            gsap.ticker.lagSmoothing(0);

            // 锚点平滑滚动
            document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
                anchor.addEventListener('click', function (e) {
                    var href = this.getAttribute('href');
                    if (!href || href === '#') return;
                    var target = document.querySelector(href);
                    if (target) {
                        e.preventDefault();
                        lenis.scrollTo(target, { offset: -60 });
                    }
                });
            });
        }

        // === 时钟（只显示到分钟，按分钟对齐刷新，避免每秒无谓渲染） ===
        var clockEl = document.getElementById('clock');
        function updateClock() {
            if (!clockEl) return;
            var now = new Date();
            clockEl.textContent = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
        }
        if (clockEl) {
            updateClock();
            var msToNextMinute = 60000 - (Date.now() % 60000);
            setTimeout(function () {
                updateClock();
                setInterval(updateClock, 60000);
            }, msToNextMinute);
        }

        // === 日历 ===
        function generateCalendar() {
            var now = new Date();
            var year = now.getFullYear();
            var month = now.getMonth();
            var today = now.getDate();
            var monthNames = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];

            var headerEl = document.getElementById('calendar-month-year');
            if (headerEl) headerEl.textContent = year + '年 ' + monthNames[month];

            var datesContainer = document.getElementById('calendar-dates');
            if (!datesContainer) return;

            var firstDayOfMonth = new Date(year, month, 1).getDay();
            var startDay = firstDayOfMonth === 0 ? 6 : firstDayOfMonth - 1;
            var daysInMonth = new Date(year, month + 1, 0).getDate();

            var frag = document.createDocumentFragment();

            for (var i = 0; i < startDay; i++) {
                var emptyCell = document.createElement('div');
                emptyCell.className = 'calendar-date empty';
                frag.appendChild(emptyCell);
            }

            for (var day = 1; day <= daysInMonth; day++) {
                var dateCell = document.createElement('div');
                dateCell.className = 'calendar-date';
                dateCell.textContent = String(day);
                if (day === today) {
                    dateCell.classList.add('today');
                    dateCell.setAttribute('aria-current', 'date');
                }
                frag.appendChild(dateCell);
            }

            datesContainer.textContent = '';
            datesContainer.appendChild(frag);
        }

        generateCalendar();
    });
})();
