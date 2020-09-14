Функция СоответствиеВМассив(Словарь) Экспорт
	МассивЭлементов = Новый Массив;
	Для Каждого ЭлементСоответствия Из Словарь Цикл
		МассивЭлементов.Добавить(ЭлементСоответствия.Значение);
	КонецЦикла;
	Возврат МассивЭлементов;
КонецФункции

Функция ОкончаниеСтрокиПослеРазделителя(Строка, Разделитель = ".") Экспорт
	Возврат Сред(Строка, СтрНайти(Строка, Разделитель, НаправлениеПоиска.СКонца)+1);
КонецФункции

//  Устанавливает значение переданной переменной только если есть различие. Возвращает различие.
Функция УстановитьЗначение(СсылкаНаЗначение, Значение, ЗаполнятьПустое = Истина) Экспорт
	Если НЕ ЗаполнятьПустое И НЕ ЗначениеЗаполнено(Значение) Тогда
		Возврат Ложь;
	ИначеЕсли СсылкаНаЗначение <> Значение Тогда
		СсылкаНаЗначение = Значение;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции

// Определяет идентификатор строки коллекции значений. Для коллекций, отображаемых в интерфейсе возвращается идентификатор, для
// объектных коллекций - индекс. Разделение нужно для того, чтобы была возможность идентификации строки в интерфейсе
//
// Параметры:
//	Коллекция	- ДанныеФормыДерево, ДанныеФормыКоллекция, ТабличнаяЧасть, ТаблицаЗначений, КоллекцияСтрокДереваЗначений
//	ЭлементКоллекции - ДанныеФормыЭлементКоллекции, ДанныеФормыЭлементДерева, СтрокаТабличнойЧасти, СтрокаТаблицыЗначений, СтрокаДереваЗначений
//
// Возвращаемое значение:
//	Число - индекс элемента коллекции
//
Функция ИндексСтроки(Коллекция, ЭлементКоллекции) Экспорт
	ТипЗначения = ТипЗнч(ЭлементКоллекции);
	Если ТипЗначения = Тип("ДанныеФормыЭлементКоллекции") ИЛИ ТипЗначения = Тип("ДанныеФормыЭлементДерева") Тогда
		Возврат Коллекция.Индекс(Коллекция.НайтиПоИдентификатору(ЭлементКоллекции.ПолучитьИдентификатор()));
	Иначе//СтрокаТабличнойЧасти, СтрокаТаблицыЗначений, СтрокаДереваЗначений
		Возврат Коллекция.Индекс(ЭлементКоллекции);
	КонецЕсли;
КонецФункции

Процедура ПереместитьЗначенияСвойств(Отправитель, Получатель, Свойства, ПеремещатьНеСуществующие = Ложь) Экспорт
	Перем ЗначениеСвойства;
	Если Получатель = Неопределено Тогда
		Получатель = Новый Структура;
	КонецЕсли;
	МассивСвойств = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Свойства,,, Истина);
	Для каждого КлючСвойства Из МассивСвойств Цикл
		Если Отправитель.Свойство(КлючСвойства, ЗначениеСвойства) ИЛИ ПеремещатьНеСуществующие Тогда
			Получатель.Вставить(КлючСвойства, ЗначениеСвойства);
			Отправитель.Удалить(КлючСвойства);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры // ЗаполнитьЗначенияСвойствРаздельно()

// Возвращает массив в свойств. Требования к свойствам такие же как при объявлении структуры.
// 
// Параметры:
//	Значение	- Строка - свойства через запятую 
//              - Массив - возвращается в исходном массиве
// Возвращаемое значение:
//	Массив - массив свойств
//
Функция Массив(Значение) Экспорт
	ТипЗначения = ТипЗнч(Значение);
	Если ТипЗначения = Тип("Массив") Тогда
		Возврат Значение;
	КонецЕсли;
	Если ТипЗначения = Тип("Строка") И НЕ ПустаяСтрока(Значение) Тогда
		Возврат СтрРазделить(СтрЗаменить(СтрЗаменить(Значение, " ", ""), Символы.ПС, ""), ",", Ложь);
	КонецЕсли;
	Возврат Новый Массив;
КонецФункции

Функция СтруктураСодержитСвойства(ТестируемаяСтруктура, НаименованияСвойств) Экспорт
	СодержитСвойства	= Истина;
	мСвойства			= СтрРазделить(СтрЗаменить(НаименованияСвойств, " ", ""), ",", Ложь);
	Для Каждого ИмяСвойства Из мСвойства Цикл
		Если НЕ ТестируемаяСтруктура.Свойство(ИмяСвойства) Тогда
			СодержитСвойства = Ложь;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Возврат СодержитСвойства;
КонецФункции

Процедура УдалитьСвойстваСтруктуры(ЦелеваяСтруктура, НаименованияСвойств) Экспорт
	мСвойства			= СтрРазделить(СтрЗаменить(НаименованияСвойств, " ", ""), ",", Ложь);
	Для Каждого ИмяСвойства Из мСвойства Цикл
		Если ЦелеваяСтруктура.Свойство(ИмяСвойства) Тогда
			ЦелеваяСтруктура.Удалить(ИмяСвойства);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
