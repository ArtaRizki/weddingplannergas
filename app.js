// Wedding Planner App - Main JavaScript

// Data Storage
const appData = {
    settings: {
        groomName: '',
        brideName: '',
        weddingDate: '',
        weddingLocation: '',
        totalBudget: 0,
        primaryColor: '#FF69B4',
        secondaryColor: '#FFB6C1',
        accentColor: '#FFD700'
    },
    budgets: [],
    vendors: [],
    todos: [],
    guests: [],
    rundowns: [],
    moodboards: []
};

// Initialize App
document.addEventListener('DOMContentLoaded', function() {
    loadDataFromStorage();
    initializeEventListeners();
    updateDashboard();
    applyThemeColors();
});

// Event Listeners
function initializeEventListeners() {
    // Navigation
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            navigateTo(this.dataset.page);
        });
    });

    // Forms
    document.getElementById('budgetForm').addEventListener('submit', addBudget);
    document.getElementById('vendorForm').addEventListener('submit', addVendor);
    document.getElementById('todoForm').addEventListener('submit', addTodo);
    document.getElementById('guestForm').addEventListener('submit', addGuest);
    document.getElementById('rundownForm').addEventListener('submit', addRundown);
    document.getElementById('settingsForm').addEventListener('submit', saveSettings);

    // Color Pickers
    document.getElementById('primaryColorInput').addEventListener('change', function() {
        appData.settings.primaryColor = this.value;
        document.getElementById('primaryColorCode').textContent = this.value;
        applyThemeColors();
        saveDataToStorage();
    });

    document.getElementById('secondaryColorInput').addEventListener('change', function() {
        appData.settings.secondaryColor = this.value;
        document.getElementById('secondaryColorCode').textContent = this.value;
        applyThemeColors();
        saveDataToStorage();
    });

    document.getElementById('accentColorInput').addEventListener('change', function() {
        appData.settings.accentColor = this.value;
        document.getElementById('accentColorCode').textContent = this.value;
        applyThemeColors();
        saveDataToStorage();
    });
}

// Navigation
function navigateTo(page) {
    // Hide all pages
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    
    // Show selected page
    document.getElementById(page).classList.add('active');
    
    // Update nav buttons
    document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`[data-page="${page}"]`).classList.add('active');

    // Refresh page data
    if (page === 'dashboard') updateDashboard();
    if (page === 'budgeting') updateBudgetDisplay();
    if (page === 'vendors') updateVendorDisplay();
    if (page === 'todo') updateTodoDisplay();
    if (page === 'guests') updateGuestDisplay();
    if (page === 'rundown') updateRundownDisplay();
    if (page === 'moodboard') updateMoodboardDisplay();
    if (page === 'settings') updateSettingsDisplay();
}

// Dashboard
function updateDashboard() {
    // Update wedding info
    document.getElementById('groomName').textContent = appData.settings.groomName || '-';
    document.getElementById('brideName').textContent = appData.settings.brideName || '-';
    document.getElementById('weddingDate').textContent = formatDate(appData.settings.weddingDate) || '-';
    document.getElementById('weddingLocation').textContent = appData.settings.weddingLocation || '-';

    // Update statistics
    const totalBudget = appData.budgets.reduce((sum, b) => sum + (b.budget || 0), 0);
    const totalSpent = appData.budgets.reduce((sum, b) => sum + (b.actual || 0), 0);
    const totalGuests = appData.guests.length;
    const completedTasks = appData.todos.filter(t => t.completed).length;

    document.getElementById('totalBudget').textContent = formatCurrency(totalBudget);
    document.getElementById('totalSpent').textContent = formatCurrency(totalSpent);
    document.getElementById('totalGuests').textContent = totalGuests;
    document.getElementById('tasksCompleted').textContent = completedTasks;

    // Update progress
    const totalTasks = appData.todos.length;
    const progress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    document.getElementById('overallProgress').style.width = progress + '%';
    document.getElementById('progressPercent').textContent = Math.round(progress) + '%';

    // Update colors
    document.getElementById('primaryColor').style.backgroundColor = appData.settings.primaryColor;
    document.getElementById('secondaryColor').style.backgroundColor = appData.settings.secondaryColor;
    document.getElementById('accentColor').style.backgroundColor = appData.settings.accentColor;
}

// Budget Management
function addBudget(e) {
    e.preventDefault();
    
    const budget = {
        id: Date.now(),
        category: document.getElementById('categoryName').value,
        budget: parseFloat(document.getElementById('budgetAmount').value),
        actual: parseFloat(document.getElementById('actualAmount').value)
    };

    appData.budgets.push(budget);
    saveDataToStorage();
    updateBudgetDisplay();
    e.target.reset();
}

function updateBudgetDisplay() {
    const tbody = document.getElementById('budgetTableBody');
    tbody.innerHTML = '';

    const totalBudget = appData.budgets.reduce((sum, b) => sum + b.budget, 0);
    const totalSpent = appData.budgets.reduce((sum, b) => sum + b.actual, 0);
    const remaining = totalBudget - totalSpent;

    appData.budgets.forEach(budget => {
        const percentage = budget.budget > 0 ? (budget.actual / budget.budget) * 100 : 0;
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${budget.category}</td>
            <td>${formatCurrency(budget.budget)}</td>
            <td>${formatCurrency(budget.actual)}</td>
            <td>${formatCurrency(budget.budget - budget.actual)}</td>
            <td>${Math.round(percentage)}%</td>
            <td>
                <button class="btn btn-secondary" onclick="editBudget(${budget.id})">Edit</button>
                <button class="btn btn-danger" onclick="deleteBudget(${budget.id})">Hapus</button>
            </td>
        `;
        tbody.appendChild(row);
    });

    // Update summary
    document.getElementById('summaryBudget').textContent = formatCurrency(totalBudget);
    document.getElementById('summarySpent').textContent = formatCurrency(totalSpent);
    document.getElementById('summaryRemaining').textContent = formatCurrency(remaining);
}

function deleteBudget(id) {
    if (confirm('Hapus kategori budget ini?')) {
        appData.budgets = appData.budgets.filter(b => b.id !== id);
        saveDataToStorage();
        updateBudgetDisplay();
    }
}

// Vendor Management
function addVendor(e) {
    e.preventDefault();
    
    const vendor = {
        id: Date.now(),
        name: document.getElementById('vendorName').value,
        category: document.getElementById('vendorCategory').value,
        phone: document.getElementById('vendorPhone').value,
        email: document.getElementById('vendorEmail').value,
        cost: parseFloat(document.getElementById('vendorCost').value) || 0,
        status: 'Aktif'
    };

    appData.vendors.push(vendor);
    saveDataToStorage();
    updateVendorDisplay();
    e.target.reset();
}

function updateVendorDisplay() {
    const vendorList = document.getElementById('vendorList');
    vendorList.innerHTML = '';

    appData.vendors.forEach(vendor => {
        const vendorCard = document.createElement('div');
        vendorCard.className = 'vendor-card';
        vendorCard.innerHTML = `
            <h4>${vendor.name}</h4>
            <div class="vendor-info">
                <span>📁 ${vendor.category}</span>
            </div>
            <div class="vendor-info">
                <span>📞 ${vendor.phone}</span>
            </div>
            ${vendor.email ? `<div class="vendor-info"><span>📧 ${vendor.email}</span></div>` : ''}
            ${vendor.cost > 0 ? `<div class="vendor-info"><span>💰 ${formatCurrency(vendor.cost)}</span></div>` : ''}
            <div class="vendor-actions">
                <button class="btn btn-secondary" onclick="editVendor(${vendor.id})">Edit</button>
                <button class="btn btn-danger" onclick="deleteVendor(${vendor.id})">Hapus</button>
            </div>
        `;
        vendorList.appendChild(vendorCard);
    });
}

function deleteVendor(id) {
    if (confirm('Hapus vendor ini?')) {
        appData.vendors = appData.vendors.filter(v => v.id !== id);
        saveDataToStorage();
        updateVendorDisplay();
    }
}

// To-Do Management
function addTodo(e) {
    e.preventDefault();
    
    const todo = {
        id: Date.now(),
        description: document.getElementById('todoDesc').value,
        category: document.getElementById('todoCategory').value,
        dueDate: document.getElementById('todoDueDate').value,
        priority: document.getElementById('todoPriority').value,
        completed: false
    };

    appData.todos.push(todo);
    saveDataToStorage();
    updateTodoDisplay();
    updateDashboard();
    e.target.reset();
}

function updateTodoDisplay() {
    const todoList = document.getElementById('todoList');
    todoList.innerHTML = '';

    // Sort by due date
    const sortedTodos = [...appData.todos].sort((a, b) => new Date(a.dueDate) - new Date(b.dueDate));

    sortedTodos.forEach(todo => {
        const todoItem = document.createElement('div');
        todoItem.className = `todo-item ${todo.completed ? 'completed' : ''}`;
        todoItem.innerHTML = `
            <input type="checkbox" class="todo-checkbox" ${todo.completed ? 'checked' : ''} 
                   onchange="toggleTodo(${todo.id})">
            <div class="todo-content">
                <div class="todo-text">${todo.description}</div>
                <div class="todo-meta">
                    <span>📁 ${todo.category}</span>
                    <span>📅 ${formatDate(todo.dueDate)}</span>
                    <span class="todo-priority ${todo.priority}">${todo.priority}</span>
                </div>
            </div>
            <div class="todo-actions">
                <button class="btn btn-secondary" onclick="editTodo(${todo.id})">Edit</button>
                <button class="btn btn-danger" onclick="deleteTodo(${todo.id})">Hapus</button>
            </div>
        `;
        todoList.appendChild(todoItem);
    });
}

function toggleTodo(id) {
    const todo = appData.todos.find(t => t.id === id);
    if (todo) {
        todo.completed = !todo.completed;
        saveDataToStorage();
        updateTodoDisplay();
        updateDashboard();
    }
}

function deleteTodo(id) {
    if (confirm('Hapus task ini?')) {
        appData.todos = appData.todos.filter(t => t.id !== id);
        saveDataToStorage();
        updateTodoDisplay();
        updateDashboard();
    }
}

// Guest Management
function addGuest(e) {
    e.preventDefault();
    
    const guest = {
        id: Date.now(),
        name: document.getElementById('guestName').value,
        side: document.getElementById('guestSide').value,
        phone: document.getElementById('guestPhone').value,
        email: document.getElementById('guestEmail').value,
        status: document.getElementById('guestStatus').value
    };

    appData.guests.push(guest);
    saveDataToStorage();
    updateGuestDisplay();
    updateDashboard();
    e.target.reset();
}

function updateGuestDisplay() {
    const tbody = document.getElementById('guestTableBody');
    tbody.innerHTML = '';

    appData.guests.forEach(guest => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${guest.name}</td>
            <td>${guest.side}</td>
            <td>${guest.phone}</td>
            <td>${guest.status}</td>
            <td>
                <button class="btn btn-secondary" onclick="editGuest(${guest.id})">Edit</button>
                <button class="btn btn-danger" onclick="deleteGuest(${guest.id})">Hapus</button>
            </td>
        `;
        tbody.appendChild(row);
    });

    // Update statistics
    const confirmed = appData.guests.filter(g => g.status === 'Konfirmasi' || g.status === 'Hadir').length;
    const pending = appData.guests.filter(g => g.status === 'Belum Diundang' || g.status === 'Diundang').length;

    document.getElementById('totalGuestCount').textContent = appData.guests.length;
    document.getElementById('confirmedCount').textContent = confirmed;
    document.getElementById('pendingCount').textContent = pending;
}

function deleteGuest(id) {
    if (confirm('Hapus tamu ini?')) {
        appData.guests = appData.guests.filter(g => g.id !== id);
        saveDataToStorage();
        updateGuestDisplay();
        updateDashboard();
    }
}

// Rundown Management
function addRundown(e) {
    e.preventDefault();
    
    const rundown = {
        id: Date.now(),
        name: document.getElementById('rundownName').value,
        time: document.getElementById('rundownTime').value,
        location: document.getElementById('rundownLocation').value,
        pic: document.getElementById('rundownPIC').value,
        notes: document.getElementById('rundownNotes').value
    };

    appData.rundowns.push(rundown);
    saveDataToStorage();
    updateRundownDisplay();
    e.target.reset();
}

function updateRundownDisplay() {
    const rundownList = document.getElementById('rundownList');
    rundownList.innerHTML = '';

    // Sort by time
    const sortedRundowns = [...appData.rundowns].sort((a, b) => a.time.localeCompare(b.time));

    sortedRundowns.forEach(rundown => {
        const rundownItem = document.createElement('div');
        rundownItem.className = 'rundown-item';
        rundownItem.innerHTML = `
            <div class="rundown-time">${rundown.time}</div>
            <div class="rundown-name">${rundown.name}</div>
            <div class="rundown-details">
                <div>📍 ${rundown.location}</div>
                <div>👤 PIC: ${rundown.pic}</div>
                ${rundown.notes ? `<div>📝 ${rundown.notes}</div>` : ''}
            </div>
            <div class="rundown-actions">
                <button class="btn btn-secondary" onclick="editRundown(${rundown.id})">Edit</button>
                <button class="btn btn-danger" onclick="deleteRundown(${rundown.id})">Hapus</button>
            </div>
        `;
        rundownList.appendChild(rundownItem);
    });
}

function deleteRundown(id) {
    if (confirm('Hapus acara ini?')) {
        appData.rundowns = appData.rundowns.filter(r => r.id !== id);
        saveDataToStorage();
        updateRundownDisplay();
    }
}

// Moodboard Management
function updateMoodboardDisplay() {
    const moodboardGrid = document.getElementById('moodboardGrid');
    moodboardGrid.innerHTML = '';

    appData.moodboards.forEach(item => {
        const moodboardItem = document.createElement('div');
        moodboardItem.className = 'moodboard-item';
        moodboardItem.innerHTML = `
            <img src="${item.url}" alt="Moodboard">
            <button class="moodboard-item-delete" onclick="deleteMoodboard(${item.id})">×</button>
        `;
        moodboardGrid.appendChild(moodboardItem);
    });
}

function addMoodboardItem() {
    const url = prompt('Masukkan URL gambar:');
    if (url) {
        const item = {
            id: Date.now(),
            url: url
        };
        appData.moodboards.push(item);
        saveDataToStorage();
        updateMoodboardDisplay();
    }
}

function deleteMoodboard(id) {
    appData.moodboards = appData.moodboards.filter(m => m.id !== id);
    saveDataToStorage();
    updateMoodboardDisplay();
}

// Settings
function updateSettingsDisplay() {
    document.getElementById('settingGroom').value = appData.settings.groomName;
    document.getElementById('settingBride').value = appData.settings.brideName;
    document.getElementById('settingDate').value = appData.settings.weddingDate;
    document.getElementById('settingLocation').value = appData.settings.weddingLocation;
    document.getElementById('settingBudget').value = appData.settings.totalBudget;
    
    document.getElementById('primaryColorInput').value = appData.settings.primaryColor;
    document.getElementById('secondaryColorInput').value = appData.settings.secondaryColor;
    document.getElementById('accentColorInput').value = appData.settings.accentColor;
    
    document.getElementById('primaryColorCode').textContent = appData.settings.primaryColor;
    document.getElementById('secondaryColorCode').textContent = appData.settings.secondaryColor;
    document.getElementById('accentColorCode').textContent = appData.settings.accentColor;
}

function saveSettings(e) {
    e.preventDefault();
    
    appData.settings.groomName = document.getElementById('settingGroom').value;
    appData.settings.brideName = document.getElementById('settingBride').value;
    appData.settings.weddingDate = document.getElementById('settingDate').value;
    appData.settings.weddingLocation = document.getElementById('settingLocation').value;
    appData.settings.totalBudget = parseFloat(document.getElementById('settingBudget').value);
    
    saveDataToStorage();
    updateDashboard();
    alert('Pengaturan berhasil disimpan!');
}

// Theme Colors
function applyThemeColors() {
    document.documentElement.style.setProperty('--primary-color', appData.settings.primaryColor);
    document.documentElement.style.setProperty('--secondary-color', appData.settings.secondaryColor);
    document.documentElement.style.setProperty('--accent-color', appData.settings.accentColor);
}

// Data Management
function saveDataToStorage() {
    localStorage.setItem('weddingPlannerData', JSON.stringify(appData));
}

function loadDataFromStorage() {
    const stored = localStorage.getItem('weddingPlannerData');
    if (stored) {
        Object.assign(appData, JSON.parse(stored));
    }
}

function exportData() {
    const dataStr = JSON.stringify(appData, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `wedding-planner-${new Date().toISOString().split('T')[0]}.json`;
    link.click();
    URL.revokeObjectURL(url);
}

function importData() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = function(e) {
        const file = e.target.files[0];
        const reader = new FileReader();
        reader.onload = function(event) {
            try {
                const imported = JSON.parse(event.target.result);
                Object.assign(appData, imported);
                saveDataToStorage();
                updateDashboard();
                alert('Data berhasil diimport!');
            } catch (error) {
                alert('Error mengimport data: ' + error.message);
            }
        };
        reader.readAsText(file);
    };
    input.click();
}

function clearAllData() {
    if (confirm('Apakah Anda yakin ingin menghapus SEMUA data? Tindakan ini tidak dapat dibatalkan!')) {
        if (confirm('Konfirmasi sekali lagi: Hapus semua data?')) {
            appData.budgets = [];
            appData.vendors = [];
            appData.todos = [];
            appData.guests = [];
            appData.rundowns = [];
            appData.moodboards = [];
            saveDataToStorage();
            updateDashboard();
            alert('Semua data telah dihapus!');
        }
    }
}

// Utility Functions
function formatCurrency(value) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0
    }).format(value);
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateStr).toLocaleDateString('id-ID', options);
}
