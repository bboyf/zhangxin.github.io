document.addEventListener('DOMContentLoaded', () => {
    // === 时钟功能 ===
    function updateClock() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        
        // 这里的 : 符号可以做一个闪烁效果，如果你喜欢的话
        document.getElementById('clock').textContent = `${hours}:${minutes}`;
    }

    // 立即运行一次，然后每秒更新
    updateClock();
    setInterval(updateClock, 1000);


    // === 日历功能 ===
    function generateCalendar() {
        const now = new Date();
        const year = now.getFullYear();
        const month = now.getMonth(); // 0-11
        const today = now.getDate();

        // 更新头部信息
        const monthNames = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
        
        // 尝试找到 ID，如果找不到可能是用户没有更新 HTML，做好兼容
        const headerEl = document.getElementById('calendar-month-year');
        if (headerEl) {
            headerEl.textContent = `${year}年 ${monthNames[month]}`;
        }
        
        // 如果有周几的显示，也更新它
        const dayEl = document.getElementById('calendar-day');
        if (dayEl) {
             const dayNames = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
             dayEl.textContent = dayNames[now.getDay()];
        }

        // 计算当月第一天是周几（0是周日，1是周一...）
        // 注意：我们的日历是从周一开始排的，所以需要转换一下
        // getDay(): 0(Sun), 1(Mon), ..., 6(Sat)
        // 目标: 0(Mon), ..., 6(Sun)
        const firstDayOfMonth = new Date(year, month, 1).getDay();
        let startDay = firstDayOfMonth === 0 ? 6 : firstDayOfMonth - 1;

        // 计算当月有多少天
        const daysInMonth = new Date(year, month + 1, 0).getDate();

        const datesContainer = document.getElementById('calendar-dates');
        if (!datesContainer) return; // 安全检查

        datesContainer.innerHTML = ''; // 清空之前的内容

        // 填充前面的空白
        for (let i = 0; i < startDay; i++) {
            const emptyCell = document.createElement('div');
            emptyCell.className = 'calendar-date empty';
            datesContainer.appendChild(emptyCell);
        }

        // 填充日期
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