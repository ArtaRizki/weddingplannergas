// Wedding Planner - Google Apps Script
// Copy isi file ini ke Code.gs di Google Apps Script

// GANTI ID INI dengan ID spreadsheet kamu
var SPREADSHEET_ID = '1OSw_Uob90L2dZVAJorykqFn0dLjxM1HSgakzsZt9eaU';

function getSpreadsheet() {
  return SpreadsheetApp.openById(SPREADSHEET_ID);
}

function doGet() {
  return HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('Wedding Planner')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

function saveData(jsonString) {
  try {
    var ss = getSpreadsheet();
    var sheet = ss.getSheetByName('_AppData');
    if (!sheet) sheet = ss.insertSheet('_AppData');
    sheet.clearContents();
    sheet.getRange('A1').setValue(jsonString);
    return 'ok';
  } catch(e) {
    return 'error: ' + e.message;
  }
}

function loadData() {
  try {
    var ss = getSpreadsheet();
    var sheet = ss.getSheetByName('_AppData');
    if (!sheet) return '';
    return sheet.getRange('A1').getValue() || '';
  } catch(e) {
    return '';
  }
}

// ============================================================
// SYNC: Membaca data dari sheet-sheet spreadsheet yang sudah ada
// Panggil fungsi ini dari web untuk import data spreadsheet
// ============================================================

function syncFromSpreadsheet() {
  var ss = getSpreadsheet();
  var result = {
    settings: getSettingsData(ss),
    seserahan: getSeserahanData(ss),
    administrasi: getAdminData(ss),
    budgets: getBudgetData(ss),
    vendors: getVendorData(ss),
    todos: getTodoData(ss),
    guests: getGuestData(ss),
    rundowns: getRundownData(ss)
  };
  return JSON.stringify(result);
}

// Baca data SETTING
function getSettingsData(ss) {
  var ws = ss.getSheetByName('SETTING');
  if (!ws) return {};
  return {
    brideName: ws.getRange('I3').getValue() || '',
    groomName: ws.getRange('K3').getValue() || ''
  };
}

// Baca data LIST SESERAHAN
function getSeserahanData(ss) {
  var ws = ss.getSheetByName('LIST SESERAHAN');
  if (!ws) return [];
  var items = [];
  var id = 1;
  
  // Grup 1: Row 4-20 (Alat Sholat=B, Tas&Sepatu=G, Baju Couple=L)
  var categories1 = [
    {col: 2, label: 'Alat Sholat', headerRow: 4},
    {col: 7, label: 'Tas & Sepatu', headerRow: 4},
    {col: 12, label: 'Baju Couple', headerRow: 4}
  ];
  categories1.forEach(function(cat) {
    for (var r = 6; r <= 20; r++) {
      var name = ws.getRange(r, cat.col).getValue();
      if (name && name.toString().trim() !== '') {
        var link = ws.getRange(r, cat.col + 1).getValue() || '';
        var harga = ws.getRange(r, cat.col + 2).getValue() || 0;
        var status = ws.getRange(r, cat.col + 3).getValue() || '';
        items.push({id: id++, n: name.toString(), s: 'Pria ke Wanita', co: harga || 0, no: cat.label + (link ? ' | Link: ' + link : '') + (status ? ' | ' + status : '')});
      }
    }
  });
  
  // Grup 2: Row 23-40 (Alat Mandi=B, Semvak=G, Skincare=L)
  var categories2 = [
    {col: 2, label: 'Alat Mandi', headerRow: 23},
    {col: 7, label: 'Semvak', headerRow: 23},
    {col: 12, label: 'Skincare', headerRow: 23}
  ];
  categories2.forEach(function(cat) {
    for (var r = 25; r <= 40; r++) {
      var name = ws.getRange(r, cat.col).getValue();
      if (name && name.toString().trim() !== '' && name !== 'Nama barang') {
        var link = ws.getRange(r, cat.col + 1).getValue() || '';
        var harga = ws.getRange(r, cat.col + 2).getValue() || 0;
        var status = ws.getRange(r, cat.col + 3).getValue() || '';
        items.push({id: id++, n: name.toString(), s: 'Pria ke Wanita', co: harga || 0, no: cat.label + (link ? ' | Link: ' + link : '') + (status ? ' | ' + status : '')});
      }
    }
  });
  
  // Grup 3: Row 42-58 (Makeup=B, Cincin=G, Box 9=L)
  var categories3 = [
    {col: 2, label: 'Makeup', headerRow: 42},
    {col: 7, label: 'Cincin', headerRow: 42},
    {col: 12, label: 'Box 9', headerRow: 42}
  ];
  categories3.forEach(function(cat) {
    for (var r = 44; r <= 58; r++) {
      var name = ws.getRange(r, cat.col).getValue();
      if (name && name.toString().trim() !== '' && name !== 'Nama barang') {
        var link = ws.getRange(r, cat.col + 1).getValue() || '';
        var harga = ws.getRange(r, cat.col + 2).getValue() || 0;
        var status = ws.getRange(r, cat.col + 3).getValue() || '';
        items.push({id: id++, n: name.toString(), s: 'Pria ke Wanita', co: harga || 0, no: cat.label + (link ? ' | Link: ' + link : '') + (status ? ' | ' + status : '')});
      }
    }
  });
  
  return items;
}

// Baca data CHECK ADMINISTRASI
function getAdminData(ss) {
  var ws = ss.getSheetByName('CHECK ADMINISTRASI');
  if (!ws) return [];
  var items = [];
  var id = 1;
  
  // Kolom B-H: Administrasi KUA (row 5-30)
  for (var r = 5; r <= 30; r++) {
    var name = ws.getRange(r, 3).getValue(); // Kolom C = Nama Dokumen
    if (name && name.toString().trim() !== '') {
      var deadline = ws.getRange(r, 4).getValue() || '';
      var pic = ws.getRange(r, 5).getValue() || '';
      var status = ws.getRange(r, 6).getValue() || '';
      var note = ws.getRange(r, 8).getValue() || '';
      items.push({
        id: id++,
        n: name.toString(),
        c: 'KUA/Gereja',
        dl: deadline ? formatDateForWeb(deadline) : '',
        no: (pic ? 'PIC: ' + pic : '') + (note ? ' | ' + note : ''),
        d: (status === 'Selesai' || status === 'Done')
      });
    }
  }
  
  // Kolom N-T: Administrasi Vendor (row 5-30)
  for (var r = 5; r <= 30; r++) {
    var name = ws.getRange(r, 15).getValue(); // Kolom O = Nama Dokumen
    if (name && name.toString().trim() !== '') {
      var deadline = ws.getRange(r, 16).getValue() || '';
      var vendor = ws.getRange(r, 17).getValue() || '';
      var status = ws.getRange(r, 18).getValue() || '';
      var note = ws.getRange(r, 20).getValue() || '';
      items.push({
        id: id++,
        n: name.toString(),
        c: 'Lainnya',
        dl: deadline ? formatDateForWeb(deadline) : '',
        no: (vendor ? 'Vendor: ' + vendor : '') + (note ? ' | ' + note : ''),
        d: (status === 'Selesai' || status === 'Done')
      });
    }
  }
  
  return items;
}

function formatDateForWeb(date) {
  try {
    if (date instanceof Date) {
      var y = date.getFullYear();
      var m = ('0' + (date.getMonth() + 1)).slice(-2);
      var d = ('0' + date.getDate()).slice(-2);
      return y + '-' + m + '-' + d;
    }
    return '';
  } catch(e) {
    return '';
  }
}

// Baca data BUDGETING
function getBudgetData(ss) {
  var ws = ss.getSheetByName('BUDGETING');
  if (!ws) return [];
  var items = [];
  var id = 1;
  // Budget Plan: kolom B=Kategori, C=Budget, D=Realisasi (row 10-30)
  for (var r = 10; r <= 30; r++) {
    var cat = ws.getRange(r, 2).getValue();
    if (cat && cat.toString().trim() !== '') {
      var budget = ws.getRange(r, 3).getValue() || 0;
      var actual = ws.getRange(r, 4).getValue() || 0;
      items.push({id: id++, n: cat.toString(), b: Number(budget) || 0, a: Number(actual) || 0});
    }
  }
  return items;
}

// Baca data VENDOR LIST
function getVendorData(ss) {
  var ws = ss.getSheetByName('VENDOR LIST');
  if (!ws) return [];
  var items = [];
  var id = 1;
  // Row 5 ke bawah: B=Nama, C=Kategori, D=CP, E=Harga, F=Kelebihan, G=Kekurangan, H=Status
  for (var r = 5; r <= 50; r++) {
    var name = ws.getRange(r, 2).getValue();
    if (name && name.toString().trim() !== '') {
      var cat = ws.getRange(r, 3).getValue() || '';
      var cp = ws.getRange(r, 4).getValue() || '';
      var harga = ws.getRange(r, 5).getValue() || 0;
      var status = ws.getRange(r, 8).getValue() || '';
      items.push({id: id++, n: name.toString(), c: cat.toString(), p: cp.toString(), e: '', co: Number(harga) || 0});
    }
  }
  return items;
}

// Baca data TO-DO-LIST
function getTodoData(ss) {
  var ws = ss.getSheetByName('TO-DO-LIST');
  if (!ws) return [];
  var items = [];
  var id = 1;
  // Grup task dimulai dari row 11 (setelah header row 10)
  // B=checkbox, C=Tugas, D=PIC, E=Tanggal, F=Deadline, G=Status, H=Catatan
  var startRows = [11, 17, 23, 29, 35];
  startRows.forEach(function(start) {
    for (var r = start; r < start + 5; r++) {
      var task = ws.getRange(r, 3).getValue();
      if (task && task.toString().trim() !== '') {
        var pic = ws.getRange(r, 4).getValue() || '';
        var deadline = ws.getRange(r, 6).getValue();
        var status = ws.getRange(r, 7).getValue() || '';
        var done = (ws.getRange(r, 2).getValue() === true || status === 'Selesai');
        items.push({
          id: id++,
          ds: task.toString(),
          c: 'Persiapan',
          dt: deadline ? formatDateForWeb(deadline) : '',
          p: 'Sedang',
          d: done
        });
      }
    }
  });
  return items;
}

// Baca data TAMU & UNDANGAN
function getGuestData(ss) {
  var ws = ss.getSheetByName('TAMU & UNDANGAN');
  if (!ws) return [];
  var items = [];
  var id = 1;
  // Row 5 ke bawah: B=No, C=Nama, D=Kategori, E=No HP, F=Bentuk Undangan, G=Status, H=RSVP
  for (var r = 5; r <= 200; r++) {
    var name = ws.getRange(r, 3).getValue();
    if (name && name.toString().trim() !== '') {
      var cat = ws.getRange(r, 4).getValue() || '';
      var phone = ws.getRange(r, 5).getValue() || '';
      var status = ws.getRange(r, 7).getValue() || 'Belum Diundang';
      var rsvp = ws.getRange(r, 8).getValue() || '';
      var side = 'Keluarga';
      if (cat.toString().toLowerCase().indexOf('pria') >= 0) side = 'Pria';
      else if (cat.toString().toLowerCase().indexOf('wanita') >= 0) side = 'Wanita';
      items.push({id: id++, n: name.toString(), s: side, p: phone.toString(), e: '', st: rsvp ? rsvp.toString() : (status ? status.toString() : 'Belum Diundang')});
    }
  }
  return items;
}

// Baca data RUNDOWN ACARA
function getRundownData(ss) {
  var ws = ss.getSheetByName('RUNDOWN ACARA');
  if (!ws) return [];
  var items = [];
  var id = 1;
  // 4 blok rundown: kolom B, J, R, Z (masing-masing mulai row 9)
  var blocks = [
    {col: 2, nameRow: 5, locRow: 6, dateRow: 4},
    {col: 10, nameRow: 5, locRow: 6, dateRow: 4},
    {col: 18, nameRow: 5, locRow: 6, dateRow: 4},
    {col: 26, nameRow: 5, locRow: 6, dateRow: 4}
  ];
  blocks.forEach(function(block) {
    var acaraName = ws.getRange(block.nameRow, block.col).getValue() || '';
    var loc = ws.getRange(block.locRow, block.col).getValue() || '';
    // Row 9 ke bawah: Nama Kegiatan, Waktu Mulai, Waktu Selesai, Durasi, Detail, PIC, Catatan
    for (var r = 9; r <= 30; r++) {
      var kegiatan = ws.getRange(r, block.col).getValue();
      if (kegiatan && kegiatan.toString().trim() !== '') {
        var waktuMulai = ws.getRange(r, block.col + 1).getValue();
        var pic = ws.getRange(r, block.col + 5).getValue() || '';
        var catatan = ws.getRange(r, block.col + 6).getValue() || '';
        var timeStr = '';
        if (waktuMulai instanceof Date) {
          timeStr = ('0' + waktuMulai.getHours()).slice(-2) + ':' + ('0' + waktuMulai.getMinutes()).slice(-2);
        } else if (waktuMulai) {
          timeStr = waktuMulai.toString();
        }
        items.push({
          id: id++,
          n: kegiatan.toString(),
          t: timeStr,
          l: loc.toString() || acaraName.toString(),
          p: pic.toString(),
          no: catatan.toString()
        });
      }
    }
  });
  return items;
}
