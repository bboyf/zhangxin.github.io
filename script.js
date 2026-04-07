document.addEventListener('DOMContentLoaded', () => {
    
    // === Toast 提示功能 ===
    let toastTimer;
    function showToast(msg) {
        const t = document.getElementById('toast');
        if (!t) return;
        t.textContent = msg;
        t.classList.add('show');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => t.classList.remove('show'), 2500);
    }
    window.showToast = showToast;

    // === 移动端菜单 ===
    const menuBtn = document.getElementById('menuBtn');
    const mobileMenu = document.getElementById('mobileMenu');
    let menuOpen = false;
    
    if (menuBtn && mobileMenu) {
        menuBtn.addEventListener('click', () => {
            menuOpen = !menuOpen;
            mobileMenu.classList.toggle('open', menuOpen);
            menuBtn.innerHTML = menuOpen ? '<i class="fas fa-times"></i>' : '<i class="fas fa-bars"></i>';
        });
        
        window.closeMobile = function() {
            menuOpen = false;
            mobileMenu.classList.remove('open');
            menuBtn.innerHTML = '<i class="fas fa-bars"></i>';
        };
    }

    // === 导航栏滚动效果 ===
    const nav = document.getElementById('nav');
    window.addEventListener('scroll', () => {
        if (nav) {
            if (window.scrollY > 50) {
                nav.classList.add('scrolled');
            } else {
                nav.classList.remove('scrolled');
            }
        }
    });

    // === 初始化页面动画 ===
    initPageAnimations();

    function initPageAnimations() {
        // 注册 ScrollTrigger
        gsap.registerPlugin(ScrollTrigger);

        // Hero 标题动画
        gsap.to('.hero-title span', {
            y: 0,
            stagger: 0.1,
            duration: 1.5,
            ease: 'power4.out'
        });

        // Hero 副标题动画
        gsap.to('.hero-sub', {
            opacity: 1,
            duration: 1,
            delay: 0.5
        });

        // 文字逐字显示动画
        document.querySelectorAll('.section-heading').forEach(el => {
            const text = el.textContent;
            el.innerHTML = '';
            text.split('').forEach(char => {
                if (char === ' ') {
                    el.innerHTML += ' ';
                } else {
                    el.innerHTML += `<span class="word-wrap"><span class="word-inner">${char}</span></span>`;
                }
            });
            gsap.to(el.querySelectorAll('.word-inner'), {
                y: '0%',
                duration: 1,
                ease: 'power3.out',
                stagger: 0.02,
                scrollTrigger: {
                    trigger: el,
                    start: 'top 85%',
                    toggleActions: 'play none none reverse'
                }
            });
        });

        // 项目列表动画
        gsap.utils.toArray('.project-item').forEach((item, i) => {
            gsap.from(item, {
                opacity: 0,
                y: 30,
                duration: 0.8,
                ease: 'power3.out',
                scrollTrigger: {
                    trigger: item,
                    start: 'top 90%',
                    toggleActions: 'play none none reverse'
                }
            });
        });

        // 技能卡片动画
        gsap.utils.toArray('.skill-card').forEach(card => {
            gsap.from(card, {
                opacity: 0,
                y: 40,
                duration: 0.8,
                ease: 'power3.out',
                scrollTrigger: {
                    trigger: card,
                    start: 'top 85%',
                    toggleActions: 'play none none reverse'
                }
            });
        });

        // 个人资料卡片动画
        gsap.from('.profile-card', {
            opacity: 0,
            y: 40,
            duration: 1,
            ease: 'power3.out',
            scrollTrigger: {
                trigger: '.profile-card',
                start: 'top 85%'
            }
        });

        // 小部件卡片动画
        gsap.from('.widget-card', {
            opacity: 0,
            y: 30,
            duration: 0.8,
            stagger: 0.2,
            ease: 'power3.out',
            scrollTrigger: {
                trigger: '.widgets-column',
                start: 'top 85%'
            }
        });

        // 页脚 CTA 动画
        gsap.from('.footer-cta', {
            y: 60,
            opacity: 0.5,
            scale: 0.9,
            scrollTrigger: {
                trigger: '.footer',
                start: 'top bottom',
                end: 'bottom bottom',
                scrub: true
            }
        });
    }

    // === Lenis 平滑滚动 ===
    const lenis = new Lenis({
        duration: 1.2,
        easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        direction: 'vertical',
        smooth: true
    });

    function raf(time) {
        lenis.raf(time);
        requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);

    // 同步 Lenis 和 ScrollTrigger
    lenis.on('scroll', ScrollTrigger.update);
    gsap.ticker.add((time) => lenis.raf(time * 1000));
    gsap.ticker.lagSmoothing(0);

    // 锚点平滑滚动
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href === '#') return;
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                lenis.scrollTo(target, { offset: -60 });
            }
        });
    });

    // === 时钟功能 ===
    function updateClock() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const clockEl = document.getElementById('clock');
        if (clockEl) {
            clockEl.textContent = `${hours}:${minutes}`;
        }
    }

    updateClock();
    setInterval(updateClock, 1000);

    // === 日历功能 ===
    function generateCalendar() {
        const now = new Date();
        const year = now.getFullYear();
        const month = now.getMonth();
        const today = now.getDate();

        const monthNames = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
        
        const headerEl = document.getElementById('calendar-month-year');
        if (headerEl) {
            headerEl.textContent = `${year}年 ${monthNames[month]}`;
        }

        const firstDayOfMonth = new Date(year, month, 1).getDay();
        let startDay = firstDayOfMonth === 0 ? 6 : firstDayOfMonth - 1;

        const daysInMonth = new Date(year, month + 1, 0).getDate();

        const datesContainer = document.getElementById('calendar-dates');
        if (!datesContainer) return;

        datesContainer.innerHTML = '';

        for (let i = 0; i < startDay; i++) {
            const emptyCell = document.createElement('div');
            emptyCell.className = 'calendar-date empty';
            datesContainer.appendChild(emptyCell);
        }

        for (let day = 1; day <= daysInMonth; day++) {
            const dateCell = document.createElement('div');
            dateCell.className = 'calendar-date';
            dateCell.textContent = day;

            if (day === today) {
                dateCell.classList.add('today');
            }

            datesContainer.appendChild(dateCell);
        }
    }

    generateCalendar();
});