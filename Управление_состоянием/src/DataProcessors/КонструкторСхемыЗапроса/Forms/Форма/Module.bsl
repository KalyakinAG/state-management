Перем НомерВерсии;

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьЭкранированныйТекст(Знач ТекстоваяСтрока) Экспорт
	ТекстоваяСтрока = СтрЗаменить(ТекстоваяСтрока, Символы.ПС, Символы.ПС+"|");
	ТекстоваяСтрока = СтрЗаменить(ТекстоваяСтрока, """", """""");
	Возврат ТекстоваяСтрока;
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция НачалоСтрокиПослеРазделителя(Строка, Разделитель = ".") Экспорт
	Возврат Сред(Строка, СтрНайти(Строка, Разделитель, НаправлениеПоиска.СНачала)+1);
КонецФункции

&НаКлиенте
Процедура КомандаСоздатьСхемуЗапроса(Команда)
	КомандаСоздатьСхемуЗапросаНаСервере();
КонецПроцедуры

//  Шаблон в формате: 
&НаСервере
Функция ДобавитьСтрокуМодуля(ТекстМодуля = Неопределено, ТекстШаблона, СоответствиеПараметров = Неопределено, Приставка = "")
	Перем ЗначениеПараметра;
	
	Если СтрНачинаетсяС(ТекстШаблона, "//") Тогда
		Если Объект.ДобавитьКомментарии Тогда
			ТекстМодуля.ДобавитьСтроку(ТекстШаблона);
			Возврат ТекстШаблона;
		Иначе
			Возврат "";
		КонецЕсли;
	КонецЕсли;
	
	RegExp				= Новый COMОбъект("VBScript.RegExp");
	RegExp.Multiline	= Истина;
	RegExp.Global		= Истина;
	RegExp.IgnoreCase	= Истина;
	RegExp.Pattern		= "\[([^\[\]]+)\]";// найти слова в квадратных скобках
	
	ТекстВыражения		= "";
	ИндексПозиции		= 1;
	Matches				= RegExp.Execute(ТекстШаблона);
	Для каждого Match Из Matches Цикл
		ДельтаПозиции	= Match.FirstIndex - ИндексПозиции + 1;
		ДельтаТекста	= Сред(ТекстШаблона, ИндексПозиции, ДельтаПозиции);
		ИндексПозиции	= ИндексПозиции + ДельтаПозиции + Match.Length;
		
		КлючПараметра	= Лев(Прав(Match.Value, Match.Length-1), Match.Length-2);
		Если СоответствиеПараметров = Неопределено ИЛИ Не СоответствиеПараметров.Свойство(КлючПараметра, ЗначениеПараметра) Тогда
			ЗначениеПараметра = ?(КлючПараметра = Приставка, "", Приставка) + КлючПараметра;
		КонецЕсли;
		
		ТекстВыражения	= ТекстВыражения + ДельтаТекста + ЗначениеПараметра;
	КонецЦикла;
	ДельтаТекста	= Сред(ТекстШаблона, ИндексПозиции, СтрДлина(ТекстШаблона)-ИндексПозиции+1);
	ТекстВыражения	= ТекстВыражения + ДельтаТекста;
	Если ТекстМодуля <> Неопределено Тогда
		ТекстМодуля.ДобавитьСтроку(ТекстВыражения);
	КонецЕсли;
	Возврат ТекстВыражения;
КонецФункции

//
&НаКлиентеНаСервереБезКонтекста
Функция Псевдоним(ПутьКДанным) 
	Возврат СтрЗаменить(НачалоСтрокиПослеРазделителя(ПутьКДанным, "."), ".", "");
КонецФункции

&НаСервере
Процедура ДобавитьТекстМодуляЗапросаПакета(ТекстМодуля, ЗапросПакета, Приставка = "", ЭтоВложенныйЗапрос = Ложь)
	Если ЭтоВложенныйЗапрос Тогда
		//ДобавитьСтрокуМодуля(ТекстМодуля, "//{	Вложенный запрос "+Приставка);
		ТекстМодуля.ДобавитьСтроку("//{	Вложенный запрос "+Приставка);
	КонецЕсли;
	Если ТипЗнч(ЗапросПакета) = Тип("ЗапросУничтоженияТаблицыСхемыЗапроса") Тогда	
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Запрос на уничтожение временной таблицы "+ЗапросПакета.ИмяТаблицы);
		ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.ЗапросПакета(СхемаЗапроса, ""[ИмяТаблицы]"", Истина);", Новый Структура("ИмяТаблицы", ЗапросПакета.ИмяТаблицы), Приставка);
		Возврат;
	Иначе
		Если ЗначениеЗаполнено(ЗапросПакета.ТаблицаДляПомещения) Тогда
			ДобавитьСтрокуМодуля(ТекстМодуля, "//  Запрос на создание временной таблицы "+ЗапросПакета.ТаблицаДляПомещения);
			ДобавитьСтрокуМодуля(ТекстМодуля, "[ЗапросПакета] 	= РаботаСоСхемойЗапроса.ЗапросПакета(СхемаЗапроса, ""[ТаблицаДляПомещения]"",, ОператорВыбрать);", Новый Структура("ТаблицаДляПомещения", ЗапросПакета.ТаблицаДляПомещения), Приставка);
		Иначе
			Если Не ЭтоВложенныйЗапрос Тогда
				ДобавитьСтрокуМодуля(ТекстМодуля, "//  Запрос на выборку данных");
				ДобавитьСтрокуМодуля(ТекстМодуля, "[ЗапросПакета] 	= РаботаСоСхемойЗапроса.ЗапросПакета(СхемаЗапроса,,"+?(ЗапросПакета.ВыбиратьРазрешенные, " Истина", "")+", ОператорВыбрать);",, Приставка);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	ДобавитьСтрокуМодуля(ТекстМодуля, "//  Операторы Выбрать");
	ЭтоПервыйОператор = Истина;
	Для Каждого ОператорВыбрать Из ЗапросПакета.Операторы Цикл
		ПараметрыОператора	= СтрРазделить("ВыбиратьРазличные,КоличествоПолучаемыхЗаписей,ТипОбъединения", ",");
		ЗначенияПараметровОператора = Новый Структура;
		ОписаниеКлючейПараметров	= "";
		ОписаниеЗначенийПараметров	= "";
		Для Индекс = 0 По ПараметрыОператора.ВГраница() Цикл
			Ключ		= ПараметрыОператора[Индекс];
			Значение	= ОператорВыбрать[Ключ];
			Если ЗначениеЗаполнено(Значение) И НЕ (Значение = Ложь ИЛИ Значение = ТипОбъединенияСхемыЗапроса.ОбъединитьВсе) Тогда
				ТипЗначения = ТипЗнч(Значение);
				Если ТипЗначения = Тип("Булево") Тогда
					ПредставлениеЗначения = ?(Значение, "Истина", "Ложь");
				ИначеЕсли ТипЗначения = Тип("Число") Тогда
					ПредставлениеЗначения = Строка(Значение);
				Иначе
					ПредставлениеЗначения = Строка(ТипЗначения)+"."+СтрЗаменить(Значение, " ", "");
				КонецЕсли;
				ОписаниеКлючейПараметров	= ОписаниеКлючейПараметров   + ?(ОписаниеКлючейПараметров = "", "", ", ") + Ключ;
				ОписаниеЗначенийПараметров	= ОписаниеЗначенийПараметров + ?(ОписаниеЗначенийПараметров = "", "", ", ") + ПредставлениеЗначения;
				ЗначенияПараметровОператора.Вставить(Ключ, ПредставлениеЗначения);
			КонецЕсли;
		КонецЦикла;
		Если Не ПустаяСтрока(ОписаниеКлючейПараметров) Тогда
			ОписаниеПараметров = "Новый Структура(""" + ОписаниеКлючейПараметров + """, " + ОписаниеЗначенийПараметров + ")";
			Если ЭтоПервыйОператор И НЕ ЭтоВложенныйЗапрос Тогда
				Если ЗначенияПараметровОператора.Количество()=1 Тогда
					Для каждого ЭлементЗначения Из ЗначенияПараметровОператора Цикл
						ДобавитьСтрокуМодуля(ТекстМодуля, "[ОператорВыбрать].[Параметр] = [Значение];", Новый Структура("Параметр,Значение", ЭлементЗначения.Ключ, ЭлементЗначения.Значение), Приставка);
					КонецЦикла;
				Иначе
					ДобавитьСтрокуМодуля(ТекстМодуля, "ЗаполнитьЗначенияСвойств([ОператорВыбрать], [ОписаниеПараметров]);", Новый Структура("ОписаниеПараметров", ОписаниеПараметров), Приставка);
				КонецЕсли; 
			Иначе
				Если НЕ ЭтоПервыйОператор Тогда
					Если ЗначенияПараметровОператора.Свойство("ТипОбъединения") И ЗначенияПараметровОператора.ТипОбъединения = "ТипОбъединенияСхемыЗапроса.Объединить" Тогда
						ТекстМодуля.ДобавитьСтроку("//  ОБЪЕДИНИТЬ");
					Иначе 
						ТекстМодуля.ДобавитьСтроку("//  ОБЪЕДИНИТЬ ВСЕ");
					КонецЕсли; 
				КонецЕсли; 
				ДобавитьСтрокуМодуля(ТекстМодуля, "[ОператорВыбрать] = РаботаСоСхемойЗапроса.Оператор([ЗапросПакета], [ОписаниеПараметров]);", Новый Структура("ОписаниеПараметров", ОписаниеПараметров), Приставка);
			КонецЕсли;
		ИначеЕсли НЕ ЭтоПервыйОператор ИЛИ ЭтоВложенныйЗапрос Тогда
			ТекстМодуля.ДобавитьСтроку("//  ОБЪЕДИНИТЬ ВСЕ");
			ДобавитьСтрокуМодуля(ТекстМодуля, "[ОператорВыбрать] = РаботаСоСхемойЗапроса.Оператор([ЗапросПакета]);", , Приставка);
		КонецЕсли;
		Если ЭтоПервыйОператор Тогда
			ЭтоПервыйОператор = Ложь;
		КонецЕсли;
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Источники");
		Для Каждого Источник Из ОператорВыбрать.Источники Цикл
			Псевдоним		= Источник.Источник.Псевдоним;
			ТипИсточника	= ТипЗнч(Источник.Источник);
			Если ТипИсточника = Тип("ВложенныйЗапросСхемыЗапроса") Тогда
				_Приставка = Приставка + ?(Псевдоним = "ВложенныйЗапрос", "", "ВложенныйЗапрос")+ Псевдоним;
				ДобавитьСтрокуМодуля(ТекстМодуля, "[ЗапросПакета] = РаботаСоСхемойЗапроса.Источник([ОператорВыбрать], РаботаСоСхемойЗапроса.ОписаниеВложенногоЗапроса(), ""[Псевдоним]"").Источник.Запрос;", Новый Структура("ОператорВыбрать, Псевдоним", Приставка+"ОператорВыбрать", Псевдоним), _Приставка);
				ДобавитьТекстМодуляЗапросаПакета(ТекстМодуля, Источник.Источник.Запрос, _Приставка, Истина);
			Иначе
				ИмяТаблицы	= Источник.Источник.ИмяТаблицы;
				Если ТипИсточника = Тип("ОписаниеВременнойТаблицыСхемыЗапроса") Тогда
					ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Источник([ОператорВыбрать], РаботаСоСхемойЗапроса.ПолучитьОписаниеВременнойТаблицы(""[ИмяТаблицы]""), ""[Псевдоним]"");", Новый Структура("ИмяТаблицы, Псевдоним", ИмяТаблицы, Псевдоним), Приставка);
				Иначе
					СтруктураПараметров = РаботаСоСхемойЗапроса.ПараметрыВиртуальнойТаблицы(ИмяТаблицы, Источник.Источник.Параметры);
					Если СтруктураПараметров = Неопределено Тогда
						Если Псевдоним = ОбщийКлиентСервер.ОкончаниеСтрокиПослеРазделителя(ИмяТаблицы) Тогда
							ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Источник([ОператорВыбрать], ""[ИмяТаблицы]"");", Новый Структура("ИмяТаблицы, Псевдоним", ИмяТаблицы), Приставка);
						Иначе
							ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Источник([ОператорВыбрать], ""[ИмяТаблицы]"", ""[Псевдоним]"");", Новый Структура("ИмяТаблицы, Псевдоним", ИмяТаблицы, Псевдоним), Приставка);
						КонецЕсли;
					Иначе
						ОписаниеКлючейПараметров = "";
						Для Каждого ЭлементПараметра Из СтруктураПараметров Цикл
							ОписаниеКлючейПараметров = ОписаниеКлючейПараметров + ?(ОписаниеКлючейПараметров = "", "", ", ") + ЭлементПараметра.Ключ;
						КонецЦикла;
						ОписаниеЗначенийПараметров = "";
						Для Каждого ЭлементПараметра Из СтруктураПараметров Цикл
							ОписаниеЗначенийПараметров = ОписаниеЗначенийПараметров + ?(ОписаниеЗначенийПараметров = "", "", ", ") + """" + ЭлементПараметра.Значение + """";
						КонецЦикла;
						ОписаниеПараметров = "Новый Структура(""" + ОписаниеКлючейПараметров + """, " + ОписаниеЗначенийПараметров + ")";
						ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Источник([ОператорВыбрать], ""[ИмяТаблицы]"", ""[Псевдоним]"", [ОписаниеПараметров]);", Новый Структура("ИмяТаблицы, Псевдоним, ОписаниеПараметров", ИмяТаблицы, Псевдоним, ОписаниеПараметров), Приставка);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Соединения");
		Для Каждого Источник Из ОператорВыбрать.Источники Цикл
			Для Каждого Соединение Из Источник.Соединения Цикл
				ТипСоединения = Соединение.ТипСоединения;
				СоответствиеПараметров = Новый Структура;
				СоответствиеПараметров.Вставить("ИсточникСлева"	, Источник.Источник.Псевдоним);
				СоответствиеПараметров.Вставить("ИсточникСправа", Соединение.Источник.Источник.Псевдоним);
				СоответствиеПараметров.Вставить("Условие"		, ПолучитьЭкранированныйТекст(Соединение.Условие));
				СоответствиеПараметров.Вставить("ТипСоединения"	, СтрЗаменить(ТипСоединения, " ", ""));
				Если ТипСоединения = ТипСоединенияСхемыЗапроса.ЛевоеВнешнее Тогда
					ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Соединение([ОператорВыбрать], ""[ИсточникСлева]"", ""[ИсточникСправа]"", ""[Условие]"");", СоответствиеПараметров, Приставка);
				Иначе
					ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Соединение([ОператорВыбрать], ""[ИсточникСлева]"", ""[ИсточникСправа]"", ""[Условие]"", ТипСоединенияСхемыЗапроса.[ТипСоединения]);", СоответствиеПараметров, Приставка);
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		Если ОператорВыбрать.Отбор.Количество() > 0 Тогда
			ДобавитьСтрокуМодуля(ТекстМодуля, "//  Условия отборов");
			Для Каждого УсловиеОтбора Из ОператорВыбрать.Отбор Цикл
				ДобавитьСтрокуМодуля(ТекстМодуля, "[ОператорВыбрать].Отбор.Добавить(""[Условие]"");", Новый Структура("Условие", ПолучитьЭкранированныйТекст(УсловиеОтбора)), Приставка);
			КонецЦикла;
		КонецЕсли;
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Поля");
		Для Каждого Поле Из ОператорВыбрать.ВыбираемыеПоля Цикл
			Колонка 		= ЗапросПакета.Колонки.Найти(Поле);
			Псевдоним		= Псевдоним(Строка(Поле));
			Если Колонка.Поля.Количество()=1 И Псевдоним = Колонка.Псевдоним Тогда
				ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Поле([ЗапросПакета], [ОператорВыбрать],, ""[Поле]"");", Новый Структура("Поле", ПолучитьЭкранированныйТекст(Поле)), Приставка);
			Иначе
				ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Поле([ЗапросПакета], [ОператорВыбрать],, ""[Поле]"", ""[Псевдоним]"");", Новый Структура("Поле, Псевдоним", ПолучитьЭкранированныйТекст(Поле), Колонка.Псевдоним), Приставка);
			КонецЕсли;
		КонецЦикла;
		//Если ОператорВыбрать.Группировка.Количество() > 0 Тогда
		//	ДобавитьСтрокуМодуля(ТекстМодуля, "//  Группировки");
		//	Для Каждого ВыражениеГруппировки Из ОператорВыбрать.Группировка Цикл
		//		ДобавитьСтрокуМодуля(ТекстМодуля, "[ОператорВыбрать].Группировка.Добавить(""[ВыражениеГруппировки]"");", Новый Структура("ВыражениеГруппировки", ПолучитьЭкранированныйТекст(ВыражениеГруппировки)), Приставка);
		//	КонецЦикла;
		//КонецЕсли;
	КонецЦикла;
	Если ЗапросПакета.Порядок.Количество() > 0 Тогда
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Упорядочивание");
		Для Каждого ВыражениеПорядка Из ЗапросПакета.Порядок Цикл
			Элемент = ВыражениеПорядка.Элемент;
			Если ТипЗнч(Элемент) = Тип("ВыражениеСхемыЗапроса") Тогда
				Псевдоним = Строка(Элемент);
			Иначе
				Псевдоним = ВыражениеПорядка.Элемент.Псевдоним;//Тип("КолонкаСхемыЗапроса")
			КонецЕсли;
			Если ВыражениеПорядка.Направление = НаправлениеПорядкаСхемыЗапроса.ПоВозрастанию Тогда
				ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Порядок([ЗапросПакета], ""[Псевдоним]"");", Новый Структура("Псевдоним", Псевдоним), Приставка);
			Иначе
				ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Порядок([ЗапросПакета], ""[Псевдоним]"", [Направление]);", Новый Структура("Псевдоним, Направление", Псевдоним, "НаправлениеПорядкаСхемыЗапроса."+СтрЗаменить(ВыражениеПорядка.Направление, " ", "")), Приставка);
			КонецЕсли;
		КонецЦикла;
		Если ЗапросПакета.Автопорядок Тогда
			ДобавитьСтрокуМодуля(ТекстМодуля, "[ЗапросПакета].Автопорядок = Истина;",, Приставка);
		КонецЕсли;
	КонецЕсли;
	Если ЗапросПакета.КонтрольныеТочкиИтогов.Количество() > 0 Тогда
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Итоги");
		Для Каждого КонтрольнаяТочкаИтогов Из ЗапросПакета.КонтрольныеТочкиИтогов Цикл
			ПараметрыОператора = Новый Массив;
			ПараметрыОператора.Добавить("""[Выражение]""");
			
			Если КонтрольнаяТочкаИтогов.Выражение <> КонтрольнаяТочкаИтогов.ИмяКолонки Тогда
				ПараметрыОператора.Добавить("""[ИмяКолонки]""");
			Иначе
				ПараметрыОператора.Добавить("");
			КонецЕсли;
			
			Если КонтрольнаяТочкаИтогов.ТипКонтрольнойТочки <> ТипКонтрольнойТочкиСхемыЗапроса.Элементы Тогда
				ПараметрыОператора.Добавить("[ТипКонтрольнойТочки]");
			Иначе
				ПараметрыОператора.Добавить("");
			КонецЕсли;
			
			Если КонтрольнаяТочкаИтогов.ТипДополненияПериодами <> ТипДополненияПериодамиСхемыЗапроса.БезДополнения Тогда
				ПараметрыОператора.Добавить("[ТипДополненияПериодами]");
				ПараметрыОператора.Добавить("""[НачалоПериодаДополнения]""");
				ПараметрыОператора.Добавить("""[КонецПериодаДополнения]""");
			КонецЕсли;
			
			ПараметрыВызова = Новый Структура;
			Если ТипЗнч(КонтрольнаяТочкаИтогов.Выражение) = Тип("ВыражениеСхемыЗапроса") Тогда
				ПараметрыВызова.Вставить("Выражение", ПолучитьЭкранированныйТекст(КонтрольнаяТочкаИтогов.Выражение));
			Иначе // КолонкаСхемыЗапроса
				ПараметрыВызова.Вставить("Выражение", ПолучитьЭкранированныйТекст(КонтрольнаяТочкаИтогов.Выражение.Псевдоним));
			КонецЕсли;
			ПараметрыВызова.Вставить("ИмяКолонки", ПолучитьЭкранированныйТекст(КонтрольнаяТочкаИтогов.ИмяКолонки));
			ПараметрыВызова.Вставить("ТипКонтрольнойТочки", "ТипКонтрольнойТочкиСхемыЗапроса."+СтрЗаменить(КонтрольнаяТочкаИтогов.ТипКонтрольнойТочки, " ", ""));
			ПараметрыВызова.Вставить("ТипДополненияПериодами", "ТипДополненияПериодамиСхемыЗапроса."+СтрЗаменить(КонтрольнаяТочкаИтогов.ТипДополненияПериодами, " ", ""));
			ПараметрыВызова.Вставить("НачалоПериодаДополнения", КонтрольнаяТочкаИтогов.НачалоПериодаДополнения);
			ПараметрыВызова.Вставить("КонецПериодаДополнения", КонтрольнаяТочкаИтогов.КонецПериодаДополнения);
			
			ДобавитьСтрокуМодуля(ТекстМодуля, "РаботаСоСхемойЗапроса.Итог([ЗапросПакета], "+СтрСоединить(ПараметрыОператора, ", ")+");", ПараметрыВызова, Приставка);
		КонецЦикла;
	КонецЕсли;
	Если ЗапросПакета.ВыраженияИтогов.Количество() > 0 Тогда
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Выражения итогов");
		Для Каждого ВыражениеИтогов Из ЗапросПакета.ВыраженияИтогов Цикл
			ДобавитьСтрокуМодуля(ТекстМодуля, "ЗапросПакета.ВыраженияИтогов.Добавить(""[Выражение]"", ""[Поле]"");", Новый Структура("Выражение, Поле", ПолучитьЭкранированныйТекст(ВыражениеИтогов.Выражение), ПолучитьЭкранированныйТекст(ВыражениеИтогов.Поле.Псевдоним)), Приставка);
		КонецЦикла;
	КонецЕсли;
	Если ЗапросПакета.ОбщиеИтоги Тогда
		ДобавитьСтрокуМодуля(ТекстМодуля, "[ЗапросПакета].ОбщиеИтоги = Истина;",, Приставка);
	КонецЕсли;
	Если ЗапросПакета.Индекс.Количество() > 0 Тогда
		ДобавитьСтрокуМодуля(ТекстМодуля, "//  Индексы");
		Для Каждого Индекс Из ЗапросПакета.Индекс Цикл
			ДобавитьСтрокуМодуля(ТекстМодуля, "ЗапросПакета.Индекс.Добавить(""[Выражение]"");", Новый Структура("Выражение", ПолучитьЭкранированныйТекст(Индекс.Выражение.Псевдоним)), Приставка);
		КонецЦикла;
	КонецЕсли;
	Если ЭтоВложенныйЗапрос Тогда
		//ДобавитьСтрокуМодуля(ТекстМодуля, "//}	Вложенный запрос "+Приставка);
		ТекстМодуля.ДобавитьСтроку("//}	Вложенный запрос "+Приставка);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура КомандаСоздатьСхемуЗапросаНаСервере()
	СхемаЗапроса = Новый СхемаЗапроса;
	СхемаЗапроса.УстановитьТекстЗапроса(Объект.ТекстЗапроса.ПолучитьТекст());
	ТекстМодуля = Объект.ТекстМодуля;
	ТекстМодуля.Очистить();
	ДобавитьСтрокуМодуля(ТекстМодуля, "Перем СхемаЗапроса, ОператорВыбрать;");
	Сч = 0;
	Для Каждого ЗапросПакета Из СхемаЗапроса.ПакетЗапросов Цикл
		ТекстМодуля.ДобавитьСтроку("////////////////////////////////////////////////////////////////////////////////");
		ТекстМодуля.ДобавитьСтроку("//  ЗАПРОС ПАКЕТА "+Строка(Сч));
		ДобавитьТекстМодуляЗапросаПакета(ТекстМодуля, ЗапросПакета);
		Сч = Сч + 1;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура КомандаОткрытьКонструкторЗапроса(Команда)
	Конструктор			= Новый КонструкторЗапроса;
	Конструктор.Текст	= Объект.ТекстЗапроса.ПолучитьТекст();
	Оповещение			= Новый ОписаниеОповещения("ОткрытьКонструкторЗапросаЗавершение", ЭтотОбъект);
	Конструктор.Показать(Оповещение);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьКонструкторЗапросаЗавершение(ТекстЗапроса, ДополнительныеПараметры) Экспорт
	Если ТекстЗапроса <> Неопределено Тогда
		Объект.ТекстЗапроса.УстановитьТекст(ТекстЗапроса);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьТекстЗапросаИзМодуля()
	Перем СхемаЗапроса, ОператорВыбрать;
	Текст = СтрЗаменить(Объект.ТекстМодуля.ПолучитьТекст(), "Перем СхемаЗапроса, ОператорВыбрать;", "");
	Выполнить(Текст);
	Возврат СхемаЗапроса.ПолучитьТекстЗапроса();
КонецФункции

&НаКлиенте
Процедура КомандаПолучитьТекстЗапросаИзМодуля(Команда)
	Текст = Новый ТекстовыйДокумент;
	Текст.УстановитьТекст(ПолучитьТекстЗапросаИзМодуля());
	Текст.Показать("Текст запроса из схемы");
КонецПроцедуры

&НаКлиенте
Процедура КомандаТест(Команда)
	СоответствиеПараметров = Новый Структура("ЗапросПакета", "ВложенныйЗапрос");
	Сообщить(ДобавитьСтрокуМодуля(, "[ЗапросПакета] = ", СоответствиеПараметров));
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	АвтоЗаголовок = Ложь;
	Заголовок = "Конструктор схемы запроса, версия "+НомерВерсии;
КонецПроцедуры

//НомерВерсии = "1.03";// убрана группировка, т.к. схема сама генерирует поля группировки
//НомерВерсии = "1.04";// исправлен псевдоним поля порядка
//НомерВерсии = "1.05";// оптимизирован код использования псевдонимом по умолчанию
//НомерВерсии = "1.06";// добавлена установка свойства автопорядок
//НомерВерсии = "1.07";// уточнен псевдоним поля упорядочивания, когда поле не является колонкой схемы запроса
//НомерВерсии = "1.08";
// уточнено формирование псевдонимов поля и источника. Для поля псевдоним формируется как путь к полю без разделителей и источника. Аналогично для источника: полное название без разделителей
// добавлена поддержка итогов, индексов
//НомерВерсии = "2.0.0.1";// перевод на следующую версию библиотеки
//НомерВерсии = "2.0.0.3";// уточнено конструирование итогов
//НомерВерсии = "2.0.0.4";// исправлено формирование параметров оператора в оптимизированном виде. Добавлено разделение операторов ОБЪЕДИНИТЬ, добавлен постоянный комментарий для вложенных запросов
НомерВерсии = "2.0.0.5";//20200827 - добавлен псевдоним вложенного запроса