// Wedding Planner App - Main JS
document.addEventListener('DOMContentLoaded', function() {
    // Auto-dismiss alerts after 4s
    document.querySelectorAll('.alert').forEach(el => {
        setTimeout(() => { el.style.opacity = '0'; setTimeout(() => el.remove(), 300); }, 4000);
    });

    // Animate progress bars on load
    document.querySelectorAll('.progress-fill').forEach(el => {
        const w = el.style.width;
        el.style.width = '0';
        setTimeout(() => { el.style.width = w; }, 100);
    });

    // Animate progress ring
    document.querySelectorAll('.progress-ring-fill').forEach(el => {
        const offset = el.style.strokeDashoffset;
        const arr = el.style.strokeDasharray;
        el.style.strokeDashoffset = arr;
        setTimeout(() => { el.style.strokeDashoffset = offset; }, 200);
    });

    // Animate stat numbers
    document.querySelectorAll('.stat-num').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(10px)';
        setTimeout(() => {
            el.style.transition = 'all .5s ease';
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, 300);
    });
});
