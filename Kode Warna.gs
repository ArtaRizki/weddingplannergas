function getHexCode(range) {
  try {
    var sheet = SpreadsheetApp.getActiveSpreadsheet();
    var cell = sheet.getRange(range);
    return cell.getBackground();
  } catch (e) {
    return "Error";
  }
}

const PETA_FORMULA = ['I11', 'K11', 'M11', 'O11', 'Q11'];

const PETA_VISUAL = [
  { kodeSel: 'I11', sheetName: 'SETTING', targetRange: 'D5:G5' },
  { kodeSel: 'I11', sheetName: 'SETTING', targetRange: 'I2' },
  { kodeSel: 'I11', sheetName: 'SETTING', targetRange: 'K2' },
  { kodeSel: 'I11', sheetName: 'SETTING', targetRange: 'F14:G14' },
  { kodeSel: 'I11', sheetName: 'SETTING', targetRange: 'I5:I9' },

  { kodeSel: 'I11', sheetName: 'DASHBOARD', targetRange: 'B4:D4' },
  { kodeSel: 'I11', sheetName: 'DASHBOARD', targetRange: 'I4:K4' },
  { kodeSel: 'I11', sheetName: 'DASHBOARD', targetRange: 'M20:N20' },

  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B11:F11' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B17:F17' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B23:F23' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B29:F29' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B35:F35' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B41:F41' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B47:F47' },
  { kodeSel: 'I11', sheetName: 'MOODBOARD & MENU', targetRange: 'B53:F53' },

  { kodeSel: 'I11', sheetName: 'BUDGETING', targetRange: 'B9:D9' },
  { kodeSel: 'I11', sheetName: 'BUDGETING', targetRange: 'F7:K7' },

  { kodeSel: 'I11', sheetName: 'VENDOR LIST', targetRange: 'J22:L22' },

  { kodeSel: 'I11', sheetName: 'TO-DO-LIST', targetRange: 'D4:D7' },
  { kodeSel: 'I11', sheetName: 'TO-DO-LIST', targetRange: 'J10:P10' },
  { kodeSel: 'I11', sheetName: 'TO-DO-LIST', targetRange: 'J16:P16' },
  { kodeSel: 'I11', sheetName: 'TO-DO-LIST', targetRange: 'J22:P22' },
  { kodeSel: 'I11', sheetName: 'TO-DO-LIST', targetRange: 'J28:P28' },
  { kodeSel: 'I11', sheetName: 'TO-DO-LIST', targetRange: 'J34:P34' },

  { kodeSel: 'I11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L12:N12' },

  { kodeSel: 'I11', sheetName: 'POST WEDDING', targetRange: 'B7:J7' },

  { kodeSel: 'I11', sheetName: 'CHECK ADMN', targetRange: 'B9:H69' },
  { kodeSel: 'I11', sheetName: 'CHECK ADMN', targetRange: 'B5:H' },
  { kodeSel: 'I11', sheetName: 'CHECK ADMN', targetRange: 'J4:L4' },

  { kodeSel: 'K11', sheetName: 'SETTING', targetRange: 'D2:G3' },

  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'E2:H2' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'B20:D20' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'F20:G20' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'I20:K20' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'M6:M7' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'M9:M10' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'M12:M13' },
  { kodeSel: 'K11', sheetName: 'DASHBOARD', targetRange: 'M15:M16' },
  
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B6' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B12' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B18' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B24' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B30' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B36' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B42' },
  { kodeSel: 'K11', sheetName: 'MOODBOARD & MENU', targetRange: 'B48' },

  { kodeSel: 'K11', sheetName: 'BUDGETING', targetRange: 'B7:D7' },

  { kodeSel: 'K11', sheetName: 'VENDOR LIST', targetRange: 'J2:L2' },
  { kodeSel: 'K11', sheetName: 'VENDOR LIST', targetRange: 'J21:L21' },

  { kodeSel: 'K11', sheetName: 'TO-DO-LIST', targetRange: 'J2:P2' },
  { kodeSel: 'K11', sheetName: 'TO-DO-LIST', targetRange: 'B10:H10' },
  { kodeSel: 'K11', sheetName: 'TO-DO-LIST', targetRange: 'J8:P8' },

  { kodeSel: 'K11', sheetName: 'TAMU & UNDANGAN', targetRange: 'B2:J2' },
  { kodeSel: 'K11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L10:N10' },
  { kodeSel: 'K11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L14:N14' },
  { kodeSel: 'K11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P14:R14' },
  { kodeSel: 'K11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L27:N27' },
  { kodeSel: 'K11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P27:R27' },

  { kodeSel: 'K11', sheetName: 'RUNDOWN ACARA', targetRange: 'B2:H2' },
  { kodeSel: 'K11', sheetName: 'RUNDOWN ACARA', targetRange: 'J2:P2' },
  { kodeSel: 'K11', sheetName: 'RUNDOWN ACARA', targetRange: 'R2:X2' },
  { kodeSel: 'K11', sheetName: 'RUNDOWN ACARA', targetRange: 'Z2:AF2' },

  { kodeSel: 'K11', sheetName: 'POST WEDDING', targetRange: 'B2:J2' },

  { kodeSel: 'K11', sheetName: 'CHECK ADMINISTRASI', targetRange: 'N2:T2' },

  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'B5:E5' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'G4:J4' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'L5:O5' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'B23:E23' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'G24:J24' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'L23:O23' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'B43:E43' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'G42:J42' },
  { kodeSel: 'K11', sheetName: 'LIST SESERAHAN', targetRange: 'L43:O43' },

  { kodeSel: 'M11', sheetName: 'SETTING', targetRange: 'D13:D14' },
  { kodeSel: 'M11', sheetName: 'SETTING', targetRange: 'F13:G13' },
  { kodeSel: 'M11', sheetName: 'SETTING', targetRange: 'I13:I14' },

  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'F6:F7' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'F9:F10' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'F12:F13' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'F15:F16' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'B22:D22' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'B28:D28' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'B34:D34' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'B40:D40' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'M31:N31' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'M35:N35' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'M39:N39' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'M43:N43' },
  { kodeSel: 'M11', sheetName: 'DASHBOARD', targetRange: 'M47:N47' },

  { kodeSel: 'M11', sheetName: 'MOODBOARD & MENU', targetRange: 'H4:Q4' },
  { kodeSel: 'M11', sheetName: 'MOODBOARD & MENU', targetRange: 'H20:Q20' },

  { kodeSel: 'M11', sheetName: 'BUDGETING', targetRange: 'F2:K2' },
  
  { kodeSel: 'M11', sheetName: 'VENDOR LIST', targetRange: 'B4:H4' },

  { kodeSel: 'M11', sheetName: 'TO-DO-LIST', targetRange: 'B4:C7' },
  { kodeSel: 'M11', sheetName: 'TO-DO-LIST', targetRange: 'K5:K6' },
  { kodeSel: 'M11', sheetName: 'TO-DO-LIST', targetRange: 'M5:M6' },

  { kodeSel: 'M11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L4:N4' },
  { kodeSel: 'M11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L7:N7' },
  { kodeSel: 'M11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P4:R4' },
  { kodeSel: 'M11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P7:R7' },
  { kodeSel: 'M11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P10:R10' },

  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'B4:B6' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'B8:H8' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'J4:J6' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'J8:P8' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'R4:R6' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'R8:X8' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'Z4:Z6' },
  { kodeSel: 'M11', sheetName: 'RUNDOWN ACARA', targetRange: 'Z8:AF8' },

  { kodeSel: 'M11', sheetName: 'POST WEDDING', targetRange: 'C4:F4' },
  { kodeSel: 'M11', sheetName: 'POST WEDDING', targetRange: 'L2:R2' },
  { kodeSel: 'M11', sheetName: 'POST WEDDING', targetRange: 'L4:N4' },
  { kodeSel: 'M11', sheetName: 'POST WEDDING', targetRange: 'L7:R7' },

  { kodeSel: 'M11', sheetName: 'CHECK ADMINISTRASI', targetRange: 'B2:H2' },
  { kodeSel: 'M11', sheetName: 'CHECK ADMINISTRASI', targetRange: 'J24:L24' },
  { kodeSel: 'M11', sheetName: 'CHECK ADMINISTRASI', targetRange: 'N4:T4' },
  { kodeSel: 'M11', sheetName: 'CHECK ADMINISTRASI', targetRange: 'J4:L4' },

  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'F2:K2' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'B4:E4' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'G5:J5' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'L4:O4' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'B24:E24' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'G23:J23' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'L24:O24' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'B42:E42' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'G43:J43' },
  { kodeSel: 'M11', sheetName: 'LIST SESERAHAN', targetRange: 'L42:O42' },

  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'K5:K9' },
  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'D11:I11' },
  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'K11' },
  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'M11' },
  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'K19' },
  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'M19' },
  { kodeSel: 'O11', sheetName: 'SETTING', targetRange: 'K27:M27' },

  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'G6:G7' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'G9:G10' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'G12:G13' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'G15:G16' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'I22:K22' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'N6:N7' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'N9:N10' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'N12:N13' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'N15:N16' },
  { kodeSel: 'O11', sheetName: 'DASHBOARD', targetRange: 'I33:J33' },

  { kodeSel: 'O11', sheetName: 'MOODBOARD & MENU', targetRange: 'B2:F3' },
  { kodeSel: 'O11', sheetName: 'MOODBOARD & MENU', targetRange: 'H18:Q18' },

  { kodeSel: 'O11', sheetName: 'BUDGETING', targetRange: 'F9:K9' },
  { kodeSel: 'O11', sheetName: 'BUDGETING', targetRange: 'M9:N9' },
  { kodeSel: 'O11', sheetName: 'BUDGETING', targetRange: 'M13:N13' },
  { kodeSel: 'O11', sheetName: 'BUDGETING', targetRange: 'M17:N17' },

  { kodeSel: 'O11', sheetName: 'VENDOR LIST', targetRange: 'B2:H2' },

  { kodeSel: 'O11', sheetName: 'TO-DO-LIST', targetRange: 'B2:H2' },
  { kodeSel: 'O11', sheetName: 'TO-DO-LIST', targetRange: 'J5:J6' },
  { kodeSel: 'O11', sheetName: 'TO-DO-LIST', targetRange: 'L5:L6' },
  { kodeSel: 'O11', sheetName: 'TO-DO-LIST', targetRange: 'O6:P6' },

  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'B4:J4' },
  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L5:N5' },
  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L8:N8' },
  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'L11:N11' },
  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P5:R5' },
  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P8:R8' },
  { kodeSel: 'O11', sheetName: 'TAMU & UNDANGAN', targetRange: 'P11:R11' },

  { kodeSel: 'O11', sheetName: 'RUNDOWN ACARA', targetRange: 'C4:E6' },
  { kodeSel: 'O11', sheetName: 'RUNDOWN ACARA', targetRange: 'K4:M6' },
  { kodeSel: 'O11', sheetName: 'RUNDOWN ACARA', targetRange: 'S4:U6' },
  { kodeSel: 'O11', sheetName: 'RUNDOWN ACARA', targetRange: 'AA4:AC6' },

  { kodeSel: 'O11', sheetName: 'POST WEDDING', targetRange: 'C5:F5' },
  { kodeSel: 'O11', sheetName: 'POST WEDDING', targetRange: 'L5:N5' },

  { kodeSel: 'O11', sheetName: 'CHECK ADMINISTRASI', targetRange: 'B4:H4' },

  { kodeSel: 'Q11', sheetName: 'BUDGETING', targetRange: 'M10:N11' },
  { kodeSel: 'Q11', sheetName: 'BUDGETING', targetRange: 'M14:N15' },
  { kodeSel: 'Q11', sheetName: 'BUDGETING', targetRange: 'M18:N19' }

];

function refreshHexCodes() {
  const ss = SpreadsheetApp.getActive();
  const moodboardSheet = ss.getSheetByName('MOODBOARD & MENU');
  SpreadsheetApp.flush();

  PETA_FORMULA.forEach(function(cell) {
    var range = moodboardSheet.getRange(cell);
    var formula = range.getFormula();
    if (formula) {
      range.clearContent();
      SpreadsheetApp.flush();
      range.setFormula(formula);
    }
  });

  Utilities.sleep(500);

  var rulesBySheet = {}; 

  PETA_VISUAL.forEach(function(peta) {
    var hexCode = moodboardSheet.getRange(peta.kodeSel).getValue();
    if (hexCode && hexCode.startsWith('#')) {
      var targetSheet = ss.getSheetByName(peta.sheetName);
      if (targetSheet) {
        var targetRange = targetSheet.getRange(peta.targetRange);
        var rule = SpreadsheetApp.newConditionalFormatRule()
          .whenFormulaSatisfied('=TRUE')
          .setBackground(hexCode)
          .setRanges([targetRange])
          .build();

        if (!rulesBySheet[peta.sheetName]) {
          rulesBySheet[peta.sheetName] = [];
        }
        rulesBySheet[peta.sheetName].push(rule);
      }
    }
  });

  const sheetNamesInConfig = Object.keys(rulesBySheet);
  
  sheetNamesInConfig.forEach(function(sheetName){
      const sheetToClear = ss.getSheetByName(sheetName);
      if(sheetToClear) {
        sheetToClear.clearConditionalFormatRules();
      }
  });
  
  for (const sheetName in rulesBySheet) {
    var sheetToFormat = ss.getSheetByName(sheetName);
    var rulesForThisSheet = rulesBySheet[sheetName];
    sheetToFormat.setConditionalFormatRules(rulesForThisSheet);
  }
}