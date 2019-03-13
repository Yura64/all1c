﻿
#Область СлужебныеПроцедурыИФункции

Функция ПолучитьОбъектыВходящиеВПодсистемы(Версия, СписокВыбранныхПодсистем, СписокОбъектовОтбора)
	
	КоличествоОбъектовОтбора = СписокОбъектовОтбора.Количество();
	
	ЗапросПоОбъектам = Новый Запрос;
	ЗапросПоОбъектам.Текст = "
	|ВЫБРАТЬ
	|	СтруктураКонфигурации.Ссылка
	|ИЗ
	|	Справочник.СтруктураКонфигурации КАК СтруктураКонфигурации
	|ГДЕ
	|	СтруктураКонфигурации.Владелец = &Владелец
	|	И НЕ СтруктураКонфигурации.ПометкаУдаления
	|	И СтруктураКонфигурации.Подсистемы.Подсистема В (&Подсистемы)
	|	" + ?(КоличествоОбъектовОтбора > 0, "И СтруктураКонфигурации.Ссылка В (&ОбъектыОтбора)", "");
	
	ЗапросПоОбъектам.УстановитьПараметр("Владелец", Версия);
	ЗапросПоОбъектам.УстановитьПараметр("Подсистемы", СписокВыбранныхПодсистем);
	ЗапросПоОбъектам.УстановитьПараметр("ОбъектыОтбора", СписокОбъектовОтбора);
	
	ТаблицаОбъектов = ЗапросПоОбъектам.Выполнить().Выгрузить();
	
	МассивОбъектов = ТаблицаОбъектов.ВыгрузитьКолонку("Ссылка");
	
	Возврат МассивОбъектов;
	
КонецФункции

Функция ПолучитьОбъектыНеВходящиеВПодсистемы(Версия, СписокВыбранныхПодсистем, СписокОбъектовОтбора)
	
	МассивОбъектов = Новый Массив;
	
	Если СписокВыбранныхПодсистем.НайтиПоЗначению(Справочники.СтруктураКонфигурации.ПустаяСсылка()) = Неопределено Тогда
		Возврат МассивОбъектов;
	КонецЕсли;
	
	КоличествоОбъектовОтбора = СписокОбъектовОтбора.Количество();
	
	ЗапросПоОбъектам = Новый Запрос;
	ЗапросПоОбъектам.Текст = "
	|ВЫБРАТЬ
	|	СтруктураКонфигурацииПодсистемы.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ ВТ_СтруктураКонфигурацииПодсистемы
	|ИЗ
	|	Справочник.СтруктураКонфигурации.Подсистемы КАК СтруктураКонфигурацииПодсистемы
	|ГДЕ
	|	СтруктураКонфигурацииПодсистемы.Ссылка.Владелец = &Владелец
	|	И НЕ СтруктураКонфигурацииПодсистемы.Ссылка.ПометкаУдаления
	|	И СтруктураКонфигурацииПодсистемы.Ссылка.ТипОбъекта В (&ТипыОбъектов)
	|	" + ?(КоличествоОбъектовОтбора > 0, "И СтруктураКонфигурацииПодсистемы.Ссылка В (&ОбъектыОтбора)", "") + "
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СтруктураКонфигурации.Ссылка
	|ИЗ
	|	Справочник.СтруктураКонфигурации КАК СтруктураКонфигурации
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_СтруктураКонфигурацииПодсистемы КАК СтруктураКонфигурацииПодсистемы
	|		ПО (СтруктураКонфигурацииПодсистемы.Ссылка = СтруктураКонфигурации.Ссылка)
	|ГДЕ
	|	СтруктураКонфигурации.Владелец = &Владелец
	|	И НЕ СтруктураКонфигурации.ПометкаУдаления
	|	И СтруктураКонфигурацииПодсистемы.Ссылка ЕСТЬ NULL
	|	И СтруктураКонфигурации.ТипОбъекта В (&ТипыОбъектов)
	|	" + ?(КоличествоОбъектовОтбора > 0, "И СтруктураКонфигурации.Ссылка В (&ОбъектыОтбора)", "");
		
	ТипыОбъектовПодсистемы = ПолучитьТипыОбъектовВходящихВПодсистемы();
	
	ЗапросПоОбъектам.УстановитьПараметр("Владелец", Версия);
	ЗапросПоОбъектам.УстановитьПараметр("ТипыОбъектов", ТипыОбъектовПодсистемы);
	ЗапросПоОбъектам.УстановитьПараметр("ОбъектыОтбора", СписокОбъектовОтбора);
	
	ТаблицаОбъектов = ЗапросПоОбъектам.Выполнить().Выгрузить();
	
	МассивОбъектов = ТаблицаОбъектов.ВыгрузитьКолонку("Ссылка");
	
	Возврат МассивОбъектов;
	
КонецФункции

// Добавляет в список объектов для отбора родителей объектов
//
Процедура ДобавитьВОтборРодителейОбъектов(Версия, СписокОбъектов) Экспорт
	
	Для Каждого Объект Из СписокОбъектов Цикл
		
		Если Объект.Значение = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		РодительОбъекта = Объект.Значение.Родитель;
		
		Если ЗначениеЗаполнено(РодительОбъекта)
			И СписокОбъектов.НайтиПоЗначению(РодительОбъекта) = Неопределено Тогда
			
			СписокОбъектов.Добавить(РодительОбъекта);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Добавляет в список объектов для отбора детей объектов
//
Процедура ДобавитьВОтборДетейОбъектов(Версия, СписокОбъектов, Ответственный = Неопределено) Экспорт
	
	ОтборПоОтветственному = ?(ЗначениеЗаполнено(Ответственный),
		"И (СтруктураКонфигурации.Ответственный = &Ответственный ИЛИ СтруктураКонфигурации.Ответственный.Ссылка ЕСТЬ NULL)",
		"");
	
	ЗапросПоОбъектам = Новый Запрос;
	ЗапросПоОбъектам.Текст = "
	|ВЫБРАТЬ
	|	СтруктураКонфигурации.Ссылка
	|ИЗ
	|	Справочник.СтруктураКонфигурации КАК СтруктураКонфигурации
	|ГДЕ
	|	СтруктураКонфигурации.Владелец = &Владелец
	|	И НЕ СтруктураКонфигурации.ПометкаУдаления
	|	И СтруктураКонфигурации.Родитель В (&СписокРодителей)
	|	И НЕ СтруктураКонфигурации.Родитель.ТипОбъекта = &ТипОбъекта
	|	" + ОтборПоОтветственному + "
	|УПОРЯДОЧИТЬ ПО
	|	СтруктураКонфигурации.НомерПоПорядку";
	
	ЗапросПоОбъектам.УстановитьПараметр("Владелец", Версия);
	ЗапросПоОбъектам.УстановитьПараметр("ТипОбъекта", Перечисления.ТипыОбъектов.ВеткаМетаданных);
	ЗапросПоОбъектам.УстановитьПараметр("СписокРодителей", СписокОбъектов);
	ЗапросПоОбъектам.УстановитьПараметр("Ответственный", Ответственный);
	
	Выборка = ЗапросПоОбъектам.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.Ссылка.ТипОбъекта <> Перечисления.ТипыОбъектов.Подсистема Тогда
			СписокОбъектов.Добавить(Выборка.Ссылка);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Добавляет в список объектов для отбора выбранные подсистемы
//
Процедура ДобавитьВОтборПодсистемы(СписокОбъектов, СписокВыбранныхПодсистем, СписокОбъектовОтбора)
	
	Для Каждого ВыбраннаяПодсистема Из СписокВыбранныхПодсистем Цикл
		Если ЗначениеЗаполнено(СписокОбъектовОтбора) Тогда
			Если НЕ СписокОбъектовОтбора.НайтиПоЗначению(ВыбраннаяПодсистема.Значение) = Неопределено Тогда
				СписокОбъектов.Добавить(ВыбраннаяПодсистема.Значение);
			КонецЕсли;
		Иначе
			СписокОбъектов.Добавить(ВыбраннаяПодсистема.Значение);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Получает список объектов, входящих в выбранные подсистемы
//
Функция ПолучитьСписокОбъектовПоПодсистемам(Версия, СписокВыбранныхПодсистем, СписокОбъектовОтбора) Экспорт
	
	МассивОбъектовВходящихВПодсистемы = ПолучитьОбъектыВходящиеВПодсистемы(Версия, СписокВыбранныхПодсистем,
		СписокОбъектовОтбора);
	
	МассивОбъектовНеВходящихВПодсистемы = ПолучитьОбъектыНеВходящиеВПодсистемы(Версия, СписокВыбранныхПодсистем,
		СписокОбъектовОтбора);
	
	СписокОбъектов = Новый СписокЗначений;
	Для Каждого Объект Из МассивОбъектовВходящихВПодсистемы Цикл
		СписокОбъектов.Добавить(Объект);
	КонецЦикла;
	
	Для Каждого Объект Из МассивОбъектовНеВходящихВПодсистемы Цикл
		СписокОбъектов.Добавить(Объект);
	КонецЦикла;
	
	ДобавитьВОтборПодсистемы(СписокОбъектов, СписокВыбранныхПодсистем, СписокОбъектовОтбора);
	
	Возврат СписокОбъектов;
	
КонецФункции

Процедура ПолучитьОтветственногоЗаПодсистемуРекурсивно(ТекущаяСтрока, Подсистема, КэшУровней)
	Если ЗначениеЗаполнено(Подсистема.Ответственный) Тогда
		ТекущаяСтрока.Ответственный = Подсистема.Ответственный;
		Уровень = КэшУровней.Получить(Подсистема);
		Если Уровень = Неопределено Тогда
			Уровень = Подсистема.Уровень();
			КэшУровней.Вставить(Подсистема, Уровень);
		КонецЕсли;
		ТекущаяСтрока.Уровень = Уровень;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Подсистема.Родитель) Тогда
		ПолучитьОтветственногоЗаПодсистемуРекурсивно(ТекущаяСтрока, Подсистема.Родитель, КэшУровней);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьТаблицуПодсистем(Версия, ОбъектыОтбора)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Подсистемы.Ссылка КАК Ссылка,
	|	Подсистемы.Подсистема КАК Подсистема,
	|	Подсистемы.Подсистема.Ответственный КАК Ответственный,
	|	0 КАК Уровень
	|ИЗ
	|	Справочник.СтруктураКонфигурации.Подсистемы КАК Подсистемы
	|ГДЕ
	|	Подсистемы.Ссылка.Владелец = &Версия
	|	И НЕ Подсистемы.Ссылка.ПометкаУдаления
	|	И Подсистемы.Ссылка.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И (Подсистемы.Ссылка В (&ОбъектыОтбора)
	|			ИЛИ НЕ &ЕстьОбъектыОтбора)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка,
	|	Подсистема";
	
	Запрос.УстановитьПараметр("Версия", Версия);
	Запрос.УстановитьПараметр("ОбъектыОтбора", ОбъектыОтбора);
	Запрос.УстановитьПараметр("ЕстьОбъектыОтбора", ОбъектыОтбора.Количество() > 0);
	
	ТаблицаПодсистем = Запрос.Выполнить().Выгрузить();
	
	КэшУровней = Новый Соответствие;
	
	ПоследнийИндекс = ТаблицаПодсистем.Количество() - 1;
	Для Счетчик = 0 По ПоследнийИндекс Цикл
		ИндексСтроки = ПоследнийИндекс - Счетчик;
		ТекущаяСтрока = ТаблицаПодсистем[ИндексСтроки];
		
		ПолучитьОтветственногоЗаПодсистемуРекурсивно(ТекущаяСтрока, ТекущаяСтрока.Подсистема, КэшУровней);
		
		Если Счетчик = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		СледующаяСтрока = ТаблицаПодсистем[ИндексСтроки + 1];
		Если ТекущаяСтрока.Ссылка <> СледующаяСтрока.Ссылка Тогда
			Продолжить;
		КонецЕсли;
		
		Если (ТекущаяСтрока.Уровень > СледующаяСтрока.Уровень ИЛИ ТекущаяСтрока.Уровень = 0) И СледующаяСтрока.Уровень <> 0 Тогда
			ТаблицаПодсистем.Удалить(ТекущаяСтрока);
		ИначеЕсли ТекущаяСтрока.Уровень <> 0 Тогда
			ТаблицаПодсистем.Удалить(СледующаяСтрока);
		КонецЕсли;
	КонецЦикла;
	
	Возврат ТаблицаПодсистем;
	
КонецФункции

// Получает список объектов по ответственному с учетом наследования
//
Функция ПолучитьСписокОбъектовПоОтветственному(Версия, ОтветственныйСсылка, СписокОбъектовОтбора) Экспорт
	
	КоличествоОбъектовОтбора = СписокОбъектовОтбора.Количество();
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СтруктураКонфигурации.Ссылка,
	|	СтруктураКонфигурации.Ответственный
	|ПОМЕСТИТЬ втОбъектыПоОтветственному
	|ИЗ
	|	Справочник.СтруктураКонфигурации КАК СтруктураКонфигурации
	|ГДЕ
	|	СтруктураКонфигурации.Владелец = &Версия
	|	И НЕ СтруктураКонфигурации.ПометкаУдаления
	|	И СтруктураКонфигурации.ТипОбъекта В(&ТипыОбъектов)
	|	И (СтруктураКонфигурации.Ответственный = &Ответственный
	|		ИЛИ СтруктураКонфигурации.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втОбъектыПоОтветственному.Ссылка,
	|	втОбъектыПоОтветственному.Ответственный
	|ПОМЕСТИТЬ втВсяИерархия
	|ИЗ
	|	втОбъектыПоОтветственному КАК втОбъектыПоОтветственному
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	втОбъектыПоОтветственному.Ссылка.Родитель,
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный
	|ИЗ
	|	втОбъектыПоОтветственному КАК втОбъектыПоОтветственному
	|ГДЕ
	|	втОбъектыПоОтветственному.Ссылка.Родитель <> ЗНАЧЕНИЕ(Справочник.СтруктураКонфигурации.ПустаяСсылка)
	|	И (втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный = &Ответственный
	|		ИЛИ втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))
	|	И втОбъектыПоОтветственному.Ссылка.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И НЕ втОбъектыПоОтветственному.Ссылка.Родитель.ПометкаУдаления
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.ТипОбъекта В(&ТипыОбъектов)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель,
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Ответственный
	|ИЗ
	|	втОбъектыПоОтветственному КАК втОбъектыПоОтветственному
	|ГДЕ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель <> ЗНАЧЕНИЕ(Справочник.СтруктураКонфигурации.ПустаяСсылка)
	|	И (втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Ответственный = &Ответственный
	|			ИЛИ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И НЕ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.ПометкаУдаления
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.ТипОбъекта В(&ТипыОбъектов)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель,
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Ответственный
	|ИЗ
	|	втОбъектыПоОтветственному КАК втОбъектыПоОтветственному
	|ГДЕ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель <> ЗНАЧЕНИЕ(Справочник.СтруктураКонфигурации.ПустаяСсылка)
	|	И (втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Ответственный = &Ответственный
	|		ИЛИ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И НЕ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.ПометкаУдаления
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.ТипОбъекта В(&ТипыОбъектов)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель,
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Ответственный
	|ИЗ
	|	втОбъектыПоОтветственному КАК втОбъектыПоОтветственному
	|ГДЕ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель <> ЗНАЧЕНИЕ(Справочник.СтруктураКонфигурации.ПустаяСсылка)
	|	И (втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Ответственный = &Ответственный
	|		ИЛИ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И НЕ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.ПометкаУдаления
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.ТипОбъекта В(&ТипыОбъектов)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель,
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель.Ответственный
	|ИЗ
	|	втОбъектыПоОтветственному КАК втОбъектыПоОтветственному
	|ГДЕ
	|	втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель <> ЗНАЧЕНИЕ(Справочник.СтруктураКонфигурации.ПустаяСсылка)
	|	И (втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель.Ответственный = &Ответственный
	|		ИЛИ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель.Ответственный = &Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И втОбъектыПоОтветственному.Ссылка.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|	И НЕ втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель.ПометкаУдаления
	|	И втОбъектыПоОтветственному.Ссылка.Родитель.Родитель.Родитель.Родитель.Родитель.ТипОбъекта В(&ТипыОбъектов)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаПодсистем.Ссылка,
	|	ТаблицаПодсистем.Подсистема,
	|	ТаблицаПодсистем.Ответственный,
	|	ТаблицаПодсистем.Уровень
	|ПОМЕСТИТЬ Подсистемы
	|ИЗ
	|	&ТаблицаПодсистем КАК ТаблицаПодсистем
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	втВсяИерархия.Ссылка,
	|	втВсяИерархия.Ответственный
	|ПОМЕСТИТЬ втГотовыОтветственныеПоРодителю
	|ИЗ
	|	втВсяИерархия КАК втВсяИерархия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втГотовыОтветственныеПоРодителю.Ссылка,
	|	Подсистемы.Подсистема,
	|	ВЫБОР
	|		КОГДА втГотовыОтветственныеПоРодителю.Ответственный ЕСТЬ NULL
	|				ИЛИ втГотовыОтветственныеПоРодителю.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|			ТОГДА ВЫБОР
	|					КОГДА Подсистемы.Ответственный ЕСТЬ NULL
	|							ИЛИ Подсистемы.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|						ТОГДА &УниверсальныйРодитель
	|					ИНАЧЕ Подсистемы.Ответственный
	|				КОНЕЦ
	|		ИНАЧЕ втГотовыОтветственныеПоРодителю.Ответственный
	|	КОНЕЦ КАК Ответственный,
	|	Подсистемы.Уровень
	|ПОМЕСТИТЬ втГотовыВсеОтветственные
	|ИЗ
	|	втГотовыОтветственныеПоРодителю КАК втГотовыОтветственныеПоРодителю
	|		ЛЕВОЕ СОЕДИНЕНИЕ Подсистемы КАК Подсистемы
	|		ПО втГотовыОтветственныеПоРодителю.Ссылка = Подсистемы.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втГотовыВсеОтветственные.Ссылка
	|ИЗ
	|	втГотовыВсеОтветственные КАК втГотовыВсеОтветственные
	|ГДЕ
	|	втГотовыВсеОтветственные.Ответственный = &Ответственный"
		+ ?(КоличествоОбъектовОтбора > 0, " И втГотовыВсеОтветственные.Ссылка В (&ОбъектыОтбора)", "");
	
	ТипыОбъектовОтветственных = ТипыОбъектовСоздать();
	НомерТипаВеткаМетаданных = ТипыОбъектовОтветственных.Найти(Перечисления.ТипыОбъектов.ВеткаМетаданных);
	ТипыОбъектовОтветственных.Удалить(НомерТипаВеткаМетаданных);
	
	ТаблицаПодсистем = ПолучитьТаблицуПодсистем(Версия, СписокОбъектовОтбора);
	КореньКонфигурацииСсылка = ПолучитьЭлементСтруктурыМетаданных(Версия,,, Перечисления.ТипыОбъектов.Конфигурация);
	
	Запрос.УстановитьПараметр("Версия", Версия);
	Запрос.УстановитьПараметр("Ответственный", ОтветственныйСсылка);
	Запрос.УстановитьПараметр("ТипыОбъектов", ТипыОбъектовОтветственных);
	Запрос.УстановитьПараметр("ОбъектыОтбора", СписокОбъектовОтбора);
	Запрос.УстановитьПараметр("ТаблицаПодсистем", ТаблицаПодсистем);
	Запрос.УстановитьПараметр("УниверсальныйРодитель", КореньКонфигурацииСсылка.Ответственный);
	
	ТаблицаРезультат = Запрос.Выполнить().Выгрузить();
	МассивРезультат = ТаблицаРезультат.ВыгрузитьКолонку("Ссылка");
	
	СписокОбъектов = Новый СписокЗначений;
	СписокОбъектов.ЗагрузитьЗначения(МассивРезультат);
	
	Возврат СписокОбъектов;
	
КонецФункции

// Получает список объектов, входящих в оба списка объектов для отбора
//
Функция ПолучитьСписокПересечений(СписокОбъектовОтбора1, СписокОбъектовОтбора2) Экспорт
	
	СписокОбъектов = Новый СписокЗначений;
	
	Для Каждого Объект Из СписокОбъектовОтбора1 Цикл
		
		Если СписокОбъектовОтбора2.НайтиПоЗначению(Объект.Значение) <> Неопределено Тогда
			СписокОбъектов.Добавить(Объект.Значение);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СписокОбъектов;
	
КонецФункции

#КонецОбласти
