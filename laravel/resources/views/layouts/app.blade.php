<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Wedding Planner') - {{ $wedding->groom_name ?? '' }} & {{ $wedding->bride_name ?? '' }}</title>
    <meta name="description" content="Aplikasi perencanaan pernikahan dengan progress tracking dan manajemen tugas">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ asset('css/app.css') }}">
    @stack('styles')
</head>
<body>
    <svg style="position:absolute;width:0;height:0"><defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" style="stop-color:#F472B6"/><stop offset="100%" style="stop-color:#FB7185"/></linearGradient></defs></svg>
    <div class="app-container">
        <!-- Sidebar -->
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="logo">💍</div>
                <h1 class="logo-text">Wedding Planner</h1>
            </div>
            <nav class="nav-menu">
                <a href="{{ route('dashboard') }}" class="nav-link {{ request()->routeIs('dashboard') ? 'active' : '' }}">
                    <span class="nav-icon">📊</span><span class="nav-label">Dashboard</span>
                </a>
                <a href="{{ route('phases.index') }}" class="nav-link {{ request()->routeIs('phases.*') ? 'active' : '' }}">
                    <span class="nav-icon">🎯</span><span class="nav-label">Progress & Phase</span>
                </a>
                <a href="{{ route('tasks.index') }}" class="nav-link {{ request()->routeIs('tasks.*') ? 'active' : '' }}">
                    <span class="nav-icon">✅</span><span class="nav-label">To-Do List</span>
                </a>
                <a href="{{ route('budgets.index') }}" class="nav-link {{ request()->routeIs('budgets.*') ? 'active' : '' }}">
                    <span class="nav-icon">💰</span><span class="nav-label">Budgeting</span>
                </a>
                <a href="{{ route('vendors.index') }}" class="nav-link {{ request()->routeIs('vendors.*') ? 'active' : '' }}">
                    <span class="nav-icon">👥</span><span class="nav-label">Vendor List</span>
                </a>
                <a href="{{ route('guests.index') }}" class="nav-link {{ request()->routeIs('guests.*') ? 'active' : '' }}">
                    <span class="nav-icon">👫</span><span class="nav-label">Tamu & Undangan</span>
                </a>
                <a href="{{ route('rundowns.index') }}" class="nav-link {{ request()->routeIs('rundowns.*') ? 'active' : '' }}">
                    <span class="nav-icon">⏱️</span><span class="nav-label">Rundown Acara</span>
                </a>
                <a href="{{ route('settings.index') }}" class="nav-link {{ request()->routeIs('settings.*') ? 'active' : '' }}">
                    <span class="nav-icon">⚙️</span><span class="nav-label">Pengaturan</span>
                </a>
            </nav>
            <div class="sidebar-footer">
                <div class="couple-names">
                    {{ $wedding->groom_name ?? '?' }} & {{ $wedding->bride_name ?? '?' }}
                </div>
            </div>
        </aside>

        <!-- Main -->
        <main class="main-content">
            <header class="top-bar">
                <button class="menu-toggle" onclick="document.getElementById('sidebar').classList.toggle('open')">☰</button>
                <h2 class="page-title">@yield('title', 'Dashboard')</h2>
                @if($wedding->wedding_date)
                <div class="countdown-badge">
                    @php $daysLeft = now()->diffInDays($wedding->wedding_date, false); @endphp
                    @if($daysLeft > 0)
                        <span class="countdown-number">{{ (int)$daysLeft }}</span>
                        <span class="countdown-label">hari lagi</span>
                    @elseif($daysLeft == 0)
                        <span class="countdown-number">🎉</span>
                        <span class="countdown-label">Hari Ini!</span>
                    @else
                        <span class="countdown-number">✨</span>
                        <span class="countdown-label">Selesai</span>
                    @endif
                </div>
                @endif
            </header>

            @if(session('success'))
            <div class="alert alert-success" onclick="this.remove()">
                ✅ {{ session('success') }}
            </div>
            @endif

            <div class="content-area">
                @yield('content')
            </div>
        </main>
    </div>
    <script src="{{ asset('js/app.js') }}"></script>
    @stack('scripts')
</body>
</html>
