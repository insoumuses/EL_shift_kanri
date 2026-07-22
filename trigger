/**
 * 毎日トリガーから呼び出す本番用関数。
 *
 * 毎月25日より前は何もしない。
 * 25日以降のみ最終営業日かどうかを確認し、
 * 最終営業日の場合だけ runElShiftSync() を実行する。
 */
function runElShiftSyncOnLastBusinessDay() {
  const today = new Date();

  // 毎月25日より前はチェックしない。
  if (today.getDate() < 25) {
    Logger.log(
      `SKIP: before 25th. today=${elShiftFormatDateForLog_(today)}`
    );
    return;
  }

  if (!elShiftIsLastBusinessDay_(today)) {
    Logger.log(
      `SKIP: today is not the last business day. today=${elShiftFormatDateForLog_(today)}`
    );
    return;
  }

  Logger.log(
    `EXECUTE: today is the last business day. today=${elShiftFormatDateForLog_(today)}`
  );

  runElShiftSync();
}

/**
 * EL窓口シフト用の時間トリガーを作成する。
 *
 * 1回だけ手動実行してください。
 * 以降、毎日 triggerHour 時台に runElShiftSyncOnLastBusinessDay() が実行されます。
 */
function installElShiftMonthlyTrigger() {
  deleteElShiftMonthlyTriggers();

  ScriptApp.newTrigger('runElShiftSyncOnLastBusinessDay')
    .timeBased()
    .everyDays(1)
    .atHour(Number(EL_SHIFT_CONFIG.triggerHour || 10))
    .create();

  Logger.log(
    `Trigger installed: runElShiftSyncOnLastBusinessDay, every day at ${EL_SHIFT_CONFIG.triggerHour || 10}:00.`
  );
}

/**
 * 既存の EL窓口シフト用トリガーを削除する。
 * トリガーを作り直したい時に使う。
 */
function deleteElShiftMonthlyTriggers() {
  const triggers = ScriptApp.getProjectTriggers();

  triggers.forEach((trigger) => {
    if (trigger.getHandlerFunction() === 'runElShiftSyncOnLastBusinessDay') {
      ScriptApp.deleteTrigger(trigger);
      Logger.log('Deleted trigger: runElShiftSyncOnLastBusinessDay');
    }
  });
}
