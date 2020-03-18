Функция Модель(Контекст, Знач ПутьКДанным = "") Экспорт
	Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") И ПутьКДанным = "" Тогда
		ПутьКДанным = "Объект";
	КонецЕсли;
	Модель = РаботаСМодельюКлиентСервер.Модель("МодельЗаявкаНаОперацию", ПутьКДанным);

	//  Настройка зависимостей: Зависимый элемент <- Источник
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ДоговорКонтрагента", "Организация", "Отбор.Организация");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ДоговорКонтрагента", "Контрагент", "Отбор.Контрагент");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ВалютаВзаиморасчетов", "ДоговорКонтрагента",,, Новый Структура("Использование", "ЭтоВнешняяОперация"));
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ТипОперацииБюджетирование", "ВидОперации");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ПриходРасход", "ВидОперации");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "СуммаВзаиморасчетов", "СуммаДокумента");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "СуммаВзаиморасчетов", "КроссКурс");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ДвиженияОперации.СуммаВзаиморасчетов", "ДвиженияОперации.Сумма");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ДвиженияОперации.СуммаВзаиморасчетов", "КроссКурс");

	//  Для внешней операции
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "СчетКонтрагента", "Контрагент", "Отбор.Владелец",, Новый Структура("Использование", "ЭтоВнешняяОперация"));
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "СчетКонтрагента", "ВалютаДокумента", "Отбор.Валюта",, Новый Структура("Использование", "ЭтоВнешняяОперация"), Истина);
	//  Для внутренней операции
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "СчетКонтрагента", "Организация", "Отбор.Владелец",, Новый Структура("Использование", "ЭтоВнутренняяОперация"));
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "СчетКонтрагента", "ВалютаВзаиморасчетов", "Отбор.Валюта",, Новый Структура("Использование", "ЭтоВнутренняяОперация"), Истина);

	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "БанковскийСчет", "Организация", "Отбор.Владелец");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "БанковскийСчет", "ВалютаДокумента", "Отбор.Валюта",,, Истина);

	//  Чистые параметры
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ЭтоВнутренняяОперация", "ТипОперацииБюджетирование", "ТипОперации");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ЭтоВнешняяОперация", "ЭтоВнутренняяОперация");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "КроссКурс", "Дата");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "КроссКурс", "ВалютаДокумента");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "КроссКурс", "ВалютаВзаиморасчетов");
	РаботаСМодельюКлиентСервер.Связь(Контекст, Модель, "ФормаОплатыБанк", "ФормаОплаты");
	
	//  Настройка параметров состояния объекта
	Модель.Параметры["ТипОперацииБюджетирование"].Выражение = "ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Параметры.ВидОперации, ""ТипОперацииБюджетирование"")";
	Модель.Параметры["ПриходРасход"].Выражение = "ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Параметры.ВидОперации, ""ПриходРасход"")";
	Модель.Параметры["СуммаВзаиморасчетов"].Выражение = "Окр(Параметры.СуммаДокумента * Параметры.КроссКурс, 2)";
	Модель.Параметры["ДвиженияОперации.СуммаВзаиморасчетов"].Выражение = "Параметры.КроссКурс * Параметры.Сумма";
	Модель.Параметры["ДоговорКонтрагента"].ПроверкаЗаполнения = Ложь;
	Модель.Параметры["ВалютаВзаиморасчетов"].Выражение = "*";
	РаботаСМодельюКлиентСервер.ЗаполнитьСвойстваПараметра(Модель, Модель.Параметры["ДвиженияОперации"], Новый Структура("Использование", "ЭтоВнешняяОперация"));
	//  Для формы оплаты через банк
	Модель.Параметры["СчетКонтрагента"].ПриИзменении = "*";
	РаботаСМодельюКлиентСервер.ЗаполнитьСвойстваПараметра(Модель, Модель.Параметры["СчетКонтрагента"], Новый Структура("Использование", "ФормаОплатыБанк"));
	Модель.Параметры["БанковскийСчет"].ПриИзменении = "*";
	РаботаСМодельюКлиентСервер.ЗаполнитьСвойстваПараметра(Модель, Модель.Параметры["БанковскийСчет"], Новый Структура("Использование", "ФормаОплатыБанк"));
	
	//  Чистые параметры
	Модель.Параметры["ЭтоВнутренняяОперация"].Выражение = "Параметры.ТипОперации = ПредопределенноеЗначение(""Перечисление.ТипыОперацийБюжетирование.ПеремещениеМеждуМестамиХраненияСредств"")
															| ИЛИ Параметры.ТипОперации = ПредопределенноеЗначение(""Перечисление.ТипыОперацийБюжетирование.КонвертацияВалюты"")";
	Модель.Параметры["ЭтоВнешняяОперация"].Выражение = "НЕ Параметры.ЭтоВнутренняяОперация";
	Модель.Параметры["ФормаОплатыБанк"].Выражение = "Параметры.ФормаОплаты = ПредопределенноеЗначение(""Перечисление.ВидыДенежныхСредств.Безналичные"")";
	Модель.Параметры["КроссКурс"].Выражение = "*";
	Модель.Параметры["КроссКурс"].НаСервере = Истина;

	//  Специальный параметр для таблицы
	Параметр = РаботаСМодельюКлиентСервер.Параметр(Контекст, Модель, "ДвиженияОперации.ИндексСтроки");
	Параметр.ПроверкаЗаполнения = Ложь;
	
	Возврат Модель;
КонецФункции