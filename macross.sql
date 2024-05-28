-- Макрос "Проверка_штрафов"
CREATE OR REPLACE MACRO Проверка_штрафов
AS
BEGIN
  -- Подсчитываем количество записей, где сумма штрафа > 1000
  SELECT COUNT(*) AS штрафов_более_1000
  FROM Penalties
  WHERE fine_amount > 1000;

  -- Проверяем полученное значение
  IF штрафов_более_1000 > 0 THEN
    -- Выводим сообщение о наличии штрафов
    DBMS_OUTPUT.PUT_LINE('В таблице ''Нарушения'' есть записи, где сумма штрафа превышает 1000 рублей.');
  ELSE
    -- Выводим сообщение об отсутствии штрафов
    DBMS_OUTPUT.PUT_LINE('В таблице ''Нарушения'' нет записей, где сумма штрафа превышает 1000 рублей.');
  END IF;
END;

-- Вызов макроса
CALL Проверка_штрафов;


-----------------------------------------

-- Триггер "Обновление_дисквалификации"
CREATE OR REPLACE TRIGGER Обновление_дисквалификации
AFTER UPDATE ON Violations
FOR EACH ROW
AS
BEGIN
  -- Получаем ID записи в таблице "Взыскания" для данного нарушения
  DECLARE penalty_id INT;

  SELECT penalty_id
  INTO penalty_id
  FROM Penalties
  WHERE violation_code = NEW.violation_code;

  -- Проверяем, получена ли запись
  IF penalty_id IS NOT NULL THEN
    -- Обновляем поле "disqualification_period" в таблице "Взыскания"
    UPDATE Penalties
    SET disqualification_period = TO_NUMBER(NEW.disqualification_period_range)
    WHERE penalty_id = penalty_id;
  END IF;
END;

