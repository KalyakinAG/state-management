///////////////////////////////////////////////////////////////////////////////////////////////////////
//  Подсистема "Управление состоянием"
//	Автор: Калякин Андрей Г.
//  Описание размещено на ресурсе: https://infostart.ru/public/1202858/
///////////////////////////////////////////////////////////////////////////////////////////////////////

Процедура УстановитьДействие(Элемент, ИмяСобытия, Действие)
	Если НЕ ЗначениеЗаполнено(Элемент.ПолучитьДействие(ИмяСобытия)) Тогда
		Элемент.УстановитьДействие(ИмяСобытия, Действие);
	КонецЕсли;
КонецПроцедуры

Процедура УстановитьСвязьСЭлементамиФормы(Контекст, Модель, Элементы) Экспорт
	// Добавление обработчиков НачалоВыбора, ПриИзменении
	Для Каждого Элемент Из Элементы Цикл
		ТипЭлемента = ТипЗнч(Элемент);
		Если ТипЭлемента = Тип("ТаблицаФормы") ИЛИ ТипЭлемента = Тип("ПолеФормы") Тогда
			Если ТипЭлемента = Тип("ТаблицаФормы") Тогда
				УстановитьДействие(Элемент, "ПриАктивизацииСтроки", "ПриАктивизацииСтроки");
			ИначеЕсли ТипЭлемента = Тип("ПолеФормы") И Элемент.Вид = ВидПоляФормы.ПолеВвода Тогда
				УстановитьДействие(Элемент, "НачалоВыбора", "НачалоВыбора");
			КонецЕсли;
			УстановитьДействие(Элемент, "ПриИзменении", "ПриИзменении");
			_Параметр = СтрЗаменить(Элемент.ПутьКДанным, Модель.ПутьКДанным + ".", "");
			РаботаСФормойКлиентСервер.Элемент(Контекст, Модель, Элемент.Имя);
			Модель.ПараметрыЭлементов[Элемент.Имя] = _Параметр;
			ЭлементыПараметра = Модель.ЭлементыПараметров[_Параметр];
			Если ЭлементыПараметра = Неопределено Тогда
				ЭлементыПараметра = Новый Массив;
				Модель.ЭлементыПараметров[_Параметр] = ЭлементыПараметра;
			КонецЕсли;
			ЭлементыПараметра.Добавить(Элемент.Имя);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

