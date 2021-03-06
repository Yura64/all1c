﻿
#Область СлужебныеПроцедурыИФункции

#Область УстановкаФлажковТребований

Функция ПолучитьЭлементыИзКэшаУстановленныхФлажковТребований(КэшУстановленныхФлажков) Экспорт
	
	КэшУстановленныхФлажковРезультат = КэшУстановленныхФлажков.Скопировать();
	КоллекцияСтрокКэшаРезультат = КэшУстановленныхФлажковРезультат.Строки;
	КоллекцияСтрокКэшаРезультат.Очистить();
	
	МассивСтрок = КэшУстановленныхФлажков.Строки.НайтиСтроки(Новый Структура("ЭтоГруппа", Ложь));
	
	Для Каждого СтрокаКэша Из МассивСтрок Цикл
		Если КоллекцияСтрокКэшаРезультат.Найти(СтрокаКэша.РодительТребования, "РодительТребования") = Неопределено Тогда
			ЗаполнитьЗначенияСвойств(КоллекцияСтрокКэшаРезультат.Добавить(), СтрокаКэша);
		КонецЕсли;
	КонецЦикла;
	
	Возврат КэшУстановленныхФлажковРезультат;
	
КонецФункции

// Меняет значение флажка у родителя требований в зависимости от нового значения флажка одного из его потомков.
//
Процедура УстановитьФлажкиНаРодителя(Ссылка, Знач НовоеЗначение, КэшУстановленныхФлажков)

	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		Возврат;
	КонецЕсли;
	
	Родитель = Ссылка.Родитель;
	Если НЕ ЗначениеЗаполнено(Родитель) Тогда
		Возврат;
	КонецЕсли;
	
	Если ПроверкаЗаполненностиФлажковТребований(КэшУстановленныхФлажков, Родитель) И НовоеЗначение = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ИзменитьКэшУстановленныхФлажков(КэшУстановленныхФлажков, Родитель, НовоеЗначение);
	УстановитьФлажкиНаРодителя(Родитель, НовоеЗначение, КэшУстановленныхФлажков);
	
КонецПроцедуры

// Проверяет значение флагов.
//
Функция ПроверкаЗаполненностиФлажковТребований(КэшУстановленныхФлажков, Ссылка)
	
	Выборка = ПолучитьДетейТребования(Ссылка);
	Пока Выборка.Следующий() Цикл
		ЗначениеФлажка = НайтиВКэшеУстановленныхФлажков(КэшУстановленныхФлажков, Выборка.Ссылка);
		Если ЗначениеФлажка > 0 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

// Функция получает на вход требование, а возвращает всех его потомков.
// Необходима для правильного проставления флажков в карточке запуска проверки.
//
Функция ПолучитьДетейТребования(Родитель, Значение = Неопределено, ТипыОбъектов = Неопределено)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Требования.Ссылка
	|ИЗ
	|	Справочник.Требования КАК Требования
	|ГДЕ
	|	Требования.Родитель = &Родитель
	|	И НЕ Требования.ПометкаУдаления";
	Запрос.УстановитьПараметр("Родитель", Родитель);
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

// Меняет значение флажков потомков требования в зависимости от нового значения флага родителя.
//
Процедура УстановитьФлажкиНаПодчиненныеСтроки(Родитель, НовоеЗначение, КэшУстановленныхФлажков)
	
	Выборка = ПолучитьДетейТребования(Родитель);
	Пока Выборка.Следующий() Цикл
		ИзменитьКэшУстановленныхФлажков(КэшУстановленныхФлажков, Выборка.Ссылка, НовоеЗначение);
		УстановитьФлажкиНаПодчиненныеСтроки(Выборка.Ссылка, НовоеЗначение, КэшУстановленныхФлажков);
	КонецЦикла;

КонецПроцедуры

// Устанавливает флажки требованиям и группам требований.
//
Функция ПриИзмененииФлажкаТребования(КэшУстановленныхФлажков, Ссылка) Экспорт
	
	СтароеЗначение = НайтиВКэшеУстановленныхФлажков(КэшУстановленныхФлажков, Ссылка);
	НовоеЗначение = ?(СтароеЗначение = 1, 0, 1);
	
	УстановитьФлажкиПодчиненнымОбъектам(Ссылка, НовоеЗначение % 2, КэшУстановленныхФлажков);
	
	УстановитьФлажокРодителюОбъекта(Ссылка, Справочники.Требования.ПустаяСсылка(), КэшУстановленныхФлажков);
	
КонецФункции

// Устанавливает флажки ошибке, требованию и группам требований.
//
Функция ПриИзмененииФлажкаОшибки(КэшУстановленныхФлажков, Ошибка, Требование) Экспорт
	
	СтрокаТребования = НайтиСтрокуКэшаУстановленныхФлажков(КэшУстановленныхФлажков, Требование);
	Если СтрокаТребования = Неопределено Тогда
		СтрокаТребования = КэшУстановленныхФлажков.Добавить();
		СтрокаТребования.Ссылка = Требование;
	КонецЕсли;
	
	СтароеЗначение = НайтиВКэшеУстановленныхФлажков(СтрокаТребования.Строки, Ошибка);
	НовоеЗначение = ?(СтароеЗначение = 1, 0, 1);
	ИзменитьКэшУстановленныхФлажковДляОшибки(КэшУстановленныхФлажков, Требование, Ошибка, НовоеЗначение);
	
	ЕстьЗаполненные = СтрокаТребования.Строки.Количество() > 0;
	ЕстьНезаполненные = ПроверкаНевыбранныхОшибокОбъектов(СтрокаТребования.Строки, Требование);
	
	НовоеЗначение = ?(ЕстьНезаполненные, ?(ЕстьЗаполненные, 2, 0), 1);
	ИзменитьКэшУстановленныхФлажков(КэшУстановленныхФлажков, Требование, НовоеЗначение);
	
	УстановитьФлажокРодителюОбъекта(Требование, Справочники.Требования.ПустаяСсылка(), КэшУстановленныхФлажков);
	
КонецФункции

// Проверяет то, что выбранный элемент это родитель в дереве.
//
Функция ПроверкаЭтоРодитель(Ссылка)
	
	МассивОбъектов = ПолучитьПодчиненныеОбъектыПроверки(Ссылка);
	
	Возврат МассивОбъектов.Количество() > 0;
	
КонецФункции

// Проверяет есть ли заполненные потомки у объекта.
//
Функция ПроверкаЗаполненностиФлажковОбъектов(КэшУстановленныхФлажков, Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Требования.Ссылка
	|ИЗ
	|	Справочник.Требования КАК Требования
	|ГДЕ
	|	Требования.Родитель = &Ссылка
	|	И НЕ Требования.ПометкаУдаления";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СтрокаВКэше = НайтиСтрокуКэшаУстановленныхФлажков(КэшУстановленныхФлажков, Выборка.Ссылка);
		
		Если ЗначениеЗаполнено(СтрокаВКэше) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

// Проверяет есть ли незаполненные потомки у объекта.
//
Функция ПроверкаНезаполненныхФлажковОбъектов(КэшУстановленныхФлажков, Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Требования.Ссылка
	|ИЗ
	|	Справочник.Требования КАК Требования
	|ГДЕ
	|	Требования.Родитель = &Ссылка
	|	И НЕ Требования.ПометкаУдаления";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СтрокаВКэше = НайтиСтрокуКэшаУстановленныхФлажков(КэшУстановленныхФлажков, Выборка.Ссылка);
		
		Если НЕ ЗначениеЗаполнено(СтрокаВКэше) Тогда
			Возврат Истина;
		КонецЕсли;
		
		Если СтрокаВКэше.Значение = 2 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ПолучитьЗапросОшибокПоТребованиям(Ссылка = Неопределено, МассивТребований = Неопределено)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ТребованияРеализацияТребования.Ссылка КАК Требование,
	|	ПравилаОбнаруживаемыеОшибки.Ошибка КАК Ошибка
	|ИЗ
	|	Справочник.Требования.РеализацияТребования КАК ТребованияРеализацияТребования
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Правила.ОбнаруживаемыеОшибки КАК ПравилаОбнаруживаемыеОшибки
	|		ПО ТребованияРеализацияТребования.ПравилоПроверки = ПравилаОбнаруживаемыеОшибки.Ссылка
	|ГДЕ
	|	" + ?(Ссылка = Неопределено, "ТребованияРеализацияТребования.Ссылка В (&МассивТребований)",
		"ТребованияРеализацияТребования.Ссылка = &Ссылка") + "
	|	И ПравилаОбнаруживаемыеОшибки.Ссылка.ИспользуетсяПриПроверке
	|	И НЕ ПравилаОбнаруживаемыеОшибки.Ссылка.ПолуавтоматическаяПроверка
	|	И НЕ ПравилаОбнаруживаемыеОшибки.Ссылка.ПометкаУдаления
	|ИТОГИ ПО
	|	ТребованияРеализацияТребования.Ссылка";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("МассивТребований", МассивТребований);
	
	Возврат Запрос;
	
КонецФункции

// Проверяет есть ли невыбранные ошибки у требования.
//
Функция ПроверкаНевыбранныхОшибокОбъектов(КоллекцияОшибок, Ссылка)
	
	Запрос = ПолучитьЗапросОшибокПоТребованиям(Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Если НЕ ЗначениеЗаполнено(Выборка.Ошибка) Тогда
			Продолжить;
		КонецЕсли;
		
		Значение = НайтиВКэшеУстановленныхФлажков(КоллекцияОшибок, Выборка.Ошибка);
		
		Если Значение = 0 Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция УстановитьФлажкиПодчиненнымОбъектам(Знач Ссылка, НовоеЗначение, КэшУстановленныхФлажков)
	
	МассивОбъектов = ПолучитьПодчиненныеОбъектыПроверки(Ссылка, Истина);
	
	Для Каждого Объект Из МассивОбъектов Цикл
		ИзменитьКэшУстановленныхФлажков(КэшУстановленныхФлажков, Объект, НовоеЗначение);
	КонецЦикла;
	
	Запрос = ПолучитьЗапросОшибокПоТребованиям(, МассивОбъектов);
	Выборка = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока Выборка.Следующий() Цикл
		Требование = Выборка.Требование;
		ВыборкаОшибок = Выборка.Выбрать();
		Пока ВыборкаОшибок.Следующий() Цикл
			Ошибка = ВыборкаОшибок.Ошибка;
			ИзменитьКэшУстановленныхФлажковДляОшибки(КэшУстановленныхФлажков, Требование, Ошибка, НовоеЗначение);
		КонецЦикла;
	КонецЦикла;
	
КонецФункции

Функция ИзменитьКэшУстановленныхФлажковДляОшибки(КэшУстановленныхФлажков, Ссылка, Ошибка, НовоеЗначение)
	
	СтрокаТребования = НайтиСтрокуКэшаУстановленныхФлажков(КэшУстановленныхФлажков, Ссылка);
	Если СтрокаТребования = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	КоллекцияСтрокТребования = СтрокаТребования.Строки;
	СтароеЗначение = 0;
	Если КоллекцияСтрокТребования.Количество() > 0 Тогда
		СтароеЗначение = НайтиВКэшеУстановленныхФлажков(КоллекцияСтрокТребования, Ошибка);
	КонецЕсли;
	
	Если СтрокаТребования = НовоеЗначение Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если СтароеЗначение = 0 Тогда
		НоваяСтрока = КоллекцияСтрокТребования.Добавить();
		НоваяСтрока.Ссылка = Ошибка;
		НоваяСтрока.Значение = НовоеЗначение;
	ИначеЕсли НовоеЗначение = 0 Тогда
		СтрокаОшибки = НайтиСтрокуКэшаУстановленныхФлажков(КоллекцияСтрокТребования, Ошибка);
		КоллекцияСтрокТребования.Удалить(СтрокаОшибки);
	Иначе
		СтрокаОшибки = НайтиСтрокуКэшаУстановленныхФлажков(КоллекцияСтрокТребования, Ошибка);
		СтрокаОшибки.Значение = НовоеЗначение;
	КонецЕсли;
	
КонецФункции

Функция ПолучитьПодчиненныеОбъектыПроверки(Ссылка, ВИерархии = Ложь)
	
	МассивОбъектов = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Требования.Ссылка
	|ИЗ
	|	Справочник.Требования КАК Требования
	|ГДЕ
	|	НЕ Требования.ПометкаУдаления
	|	"+ ?(ВИерархии, "И Требования.Ссылка В ИЕРАРХИИ (&Ссылка)",
		"И Требования.Родитель = &Ссылка");
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Результат = Запрос.Выполнить().Выгрузить();
	МассивОбъектов = Результат.ВыгрузитьКолонку("Ссылка");
	
	Возврат МассивОбъектов;
	
КонецФункции

// Функция устанавливает флажок родителя, в зависимости от заполнения подчиненных элементов.
//
Функция УстановитьФлажокРодителюОбъекта(Знач Ссылка, ПустаяСсылка, КэшУстановленныхФлажков) Экспорт
	
	Родитель = Ссылка.Родитель;
	Если Родитель = ПустаяСсылка Тогда
		Возврат Истина;
	КонецЕсли;
	
	ЭтоГруппа = ПроверкаЭтоРодитель(Родитель);
	РодительПометка = НайтиВКэшеУстановленныхФлажков(КэшУстановленныхФлажков, Родитель);
	
	Если НЕ ЭтоГруппа И РодительПометка = 1 Тогда
		Возврат УстановитьФлажокРодителюОбъекта(Родитель, ПустаяСсылка, КэшУстановленныхФлажков);
	КонецЕсли;
	
	ЕстьНезаполненные = ПроверкаНезаполненныхФлажковОбъектов(КэшУстановленныхФлажков, Родитель);
	ЕстьЗаполненные = ПроверкаЗаполненностиФлажковОбъектов(КэшУстановленныхФлажков, Родитель);
	
	НовоеЗначение = ?(ЕстьНезаполненные, ?(ЕстьЗаполненные, 2, 0), ?(ЭтоГруппа, 1, 2));
	
	Если НЕ ЭтоГруппа И НовоеЗначение = 1 Тогда
		Возврат УстановитьФлажокРодителюОбъекта(Родитель, ПустаяСсылка, КэшУстановленныхФлажков);
	КонецЕсли;
	
	ИзменитьКэшУстановленныхФлажков(КэшУстановленныхФлажков, Родитель, НовоеЗначение);
	
	Возврат УстановитьФлажокРодителюОбъекта(Родитель, ПустаяСсылка,КэшУстановленныхФлажков);
	
КонецФункции

// Функция получает ссылку на вариант проверки по конфигурации и наименованию варианта.
//
Функция ПолучитьСсылкуВариантаПроверки(Конфигурация, ВариантПроверкиНаименование) Экспорт
	
	ВариантПроверкиСовместимо = Справочники.ВариантыПроверки.Совместимо;
	ВариантПроверкиПолнаяПроверка = Справочники.ВариантыПроверки.ПолнаяПроверка;
	
	Если ВариантПроверкиНаименование = ВариантПроверкиПолнаяПроверка.Наименование Тогда
		Возврат ВариантПроверкиПолнаяПроверка;
	ИначеЕсли ВариантПроверкиНаименование = ВариантПроверкиСовместимо.Наименование Тогда
		Возврат ВариантПроверкиСовместимо;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ВариантыПроверки.Ссылка
	|ИЗ
	|	Справочник.ВариантыПроверки КАК ВариантыПроверки
	|ГДЕ
	|	ВариантыПроверки.Конфигурация = &Конфигурация
	|	И ВариантыПроверки.Наименование = &Наименование";
	Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
	Запрос.УстановитьПараметр("Наименование", ВариантПроверкиНаименование);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Возврат Справочники.ВариантыПроверки.ПустаяСсылка();
	
КонецФункции

// Функция возвращает таблицу требований для заданной конфигурации и варианта проверки.
//
Функция ЗаполнитьТаблицуТребований(Конфигурация, ВариантПроверки) Экспорт
	
	Если ТипЗнч(ВариантПроверки) = Тип("СправочникСсылка.ВариантыПроверки") Тогда
		ВариантПроверкиСсылка = ВариантПроверки;
	ИначеЕсли ТипЗнч(ВариантПроверки) = Тип("Строка") Тогда
		ВариантПроверкиСсылка = ПолучитьСсылкуВариантаПроверки(Конфигурация, ВариантПроверки);
	Иначе
		
		КэшУстановленныхФлажковТребований = ИнициализироватьДеревоКэшаУстановленныхФлажковТребований();
		Возврат КэшУстановленныхФлажковТребований;
		
	КонецЕсли;
	
	Если ВариантПроверкиСсылка = Справочники.ВариантыПроверки.Совместимо Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Требования.Ссылка,
		|	1 КАК Значение,
		|	Требования.ЭтоГруппа КАК ЭтоГруппа,
		|	Требования.Родитель КАК РодительТребования,
		|	ПравилаОбнаруживаемыеОшибки.Ошибка КАК Ошибка,
		|	1 КАК ЗначениеОшибки
		|ИЗ
		|	Справочник.Требования КАК Требования
		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Требования.РеализацияТребования КАК ТребованияРеализацияТребования
		|	ПО Требования.Ссылка = ТребованияРеализацияТребования.Ссылка
		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Правила.ОбнаруживаемыеОшибки КАК ПравилаОбнаруживаемыеОшибки
		|	ПО ТребованияРеализацияТребования.ПравилоПроверки = ПравилаОбнаруживаемыеОшибки.Ссылка
		|ГДЕ
		|	Требования.Ссылка В ИЕРАРХИИ (&Группа)
		|	И НЕ Требования.ПометкаУдаления";
		
		Запрос.УстановитьПараметр("Группа", Справочники.Требования.Совместимо);
		
	ИначеЕсли ВариантПроверкиСсылка = Справочники.ВариантыПроверки.ПолнаяПроверка Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Требования.Ссылка,
		|	1 КАК Значение,
		|	Требования.ЭтоГруппа КАК ЭтоГруппа,
		|	Требования.Родитель КАК РодительТребования,
		|	ПравилаОбнаруживаемыеОшибки.Ошибка КАК Ошибка,
		|	1 КАК ЗначениеОшибки
		|ИЗ
		|	Справочник.Требования КАК Требования
		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Требования.РеализацияТребования КАК ТребованияРеализацияТребования
		|	ПО Требования.Ссылка = ТребованияРеализацияТребования.Ссылка
		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Правила.ОбнаруживаемыеОшибки КАК ПравилаОбнаруживаемыеОшибки
		|	ПО ТребованияРеализацияТребования.ПравилоПроверки = ПравилаОбнаруживаемыеОшибки.Ссылка
		|ГДЕ
		|	(Требования.Ссылка В ИЕРАРХИИ (&ГруппаОрфография)
		|		ИЛИ Требования.Ссылка В ИЕРАРХИИ (&ГруппаСистемаСтандартов))
		|	И НЕ Требования.ПометкаУдаления";
		
		Запрос.УстановитьПараметр("ГруппаСистемаСтандартов", Справочники.Требования.СистемаСтандартов);
		Запрос.УстановитьПараметр("ГруппаОрфография", Справочники.Требования.Орфография);
		
	Иначе
		
		Запрос = Новый Запрос;
		Запрос.Текст = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ТребованияККонфигурации.Требование КАК Требование,
		|	ТребованияККонфигурации.Ошибка КАК Ошибка
		|ПОМЕСТИТЬ ТребованияРегистра
		|ИЗ
		|	РегистрСведений.ТребованияККонфигурации КАК ТребованияККонфигурации
		|ГДЕ
		|	ТребованияККонфигурации.Конфигурация = &Конфигурация
		|	И ТребованияККонфигурации.ВариантПроверки = &ВариантПроверки
		|	И ТребованияККонфигурации.Требование.Наименование <> &ПустаяСтрока
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТребованияРегистра.Требование КАК Требование,
		|	КОЛИЧЕСТВО(ТребованияРегистра.Требование) КАК Количество
		|ПОМЕСТИТЬ КоличествоОшибокВРегистре
		|ИЗ
		|	ТребованияРегистра КАК ТребованияРегистра
		|
		|СГРУППИРОВАТЬ ПО
		|	ТребованияРегистра.Требование
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ТребованияРеализацияТребования.Ссылка КАК Требование,
		|	ПравилаОбнаруживаемыеОшибки.Ошибка КАК Ошибка
		|ПОМЕСТИТЬ ВсеОшибки
		|ИЗ
		|	Справочник.Требования.РеализацияТребования КАК ТребованияРеализацияТребования
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Правила.ОбнаруживаемыеОшибки КАК ПравилаОбнаруживаемыеОшибки
		|		ПО ТребованияРеализацияТребования.ПравилоПроверки = ПравилаОбнаруживаемыеОшибки.Ссылка
		|ГДЕ
		|	ТребованияРеализацияТребования.Ссылка.Наименование <> &ПустаяСтрока
		|	И ПравилаОбнаруживаемыеОшибки.Ссылка.ИспользуетсяПриПроверке
		|	И НЕ ПравилаОбнаруживаемыеОшибки.Ссылка.ПолуавтоматическаяПроверка
		|	И НЕ ПравилаОбнаруживаемыеОшибки.Ссылка.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВсеОшибки.Требование КАК Требование,
		|	КОЛИЧЕСТВО(ВсеОшибки.Требование) КАК Количество
		|ПОМЕСТИТЬ КоличествоОшибокВсего
		|ИЗ
		|	ВсеОшибки КАК ВсеОшибки
		|
		|СГРУППИРОВАТЬ ПО
		|	ВсеОшибки.Требование
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТребованияРегистра.Требование КАК Ссылка,
		|	ВЫБОР
		|		КОГДА ЕСТЬNULL(КоличествоОшибокВсего.Количество, 0) > ЕСТЬNULL(КоличествоОшибокВРегистре.Количество, 0)
		|			ТОГДА 2
		|		ИНАЧЕ 1
		|	КОНЕЦ КАК Значение,
		|	ТребованияРегистра.Требование.ЭтоГруппа КАК ЭтоГруппа,
		|	ТребованияРегистра.Требование.Родитель КАК РодительТребования,
		|	ТребованияРегистра.Ошибка КАК Ошибка,
		|	1 КАК ЗначениеОшибки
		|ИЗ
		|	ТребованияРегистра КАК ТребованияРегистра
		|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоОшибокВРегистре КАК КоличествоОшибокВРегистре
		|		ПО ТребованияРегистра.Требование = КоличествоОшибокВРегистре.Требование
		|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоОшибокВсего КАК КоличествоОшибокВсего
		|		ПО ТребованияРегистра.Требование = КоличествоОшибокВсего.Требование";
		
		Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
		Запрос.УстановитьПараметр("ВариантПроверки", ВариантПроверкиСсылка);
		Запрос.УстановитьПараметр("ПустаяСтрока", "");
		
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Дерево = ИнициализироватьДеревоКэшаУстановленныхФлажковТребований();
	
	КопияРезультата = РезультатЗапроса.Скопировать(, "Ссылка");
	КопияРезультата.Свернуть("Ссылка");
	
	Для Каждого СтрокаТаблицы Из КопияРезультата Цикл
		
		СтруктураПоиска = Новый Структура;
		СтруктураПоиска.Вставить("Ссылка", СтрокаТаблицы.Ссылка);
		МассивСтрок = РезультатЗапроса.НайтиСтроки(СтруктураПоиска);
		
		НоваяСтрокаДерева = Дерево.Строки.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрокаДерева, МассивСтрок[0]);
		
		Для Каждого СтрокаМассива Из МассивСтрок Цикл
			
			Если НЕ ЗначениеЗаполнено(СтрокаМассива.Ошибка) Тогда
				Продолжить;
			КонецЕсли;
			
			СтрокаОшибки = НоваяСтрокаДерева.Строки.Добавить();
			СтрокаОшибки.Значение = СтрокаМассива.ЗначениеОшибки;
			СтрокаОшибки.Ссылка = СтрокаМассива.Ошибка;
		КонецЦикла;
	КонецЦикла;
	
	КэшУстановленныхФлажков = Дерево;
	
	Возврат КэшУстановленныхФлажков;
	
КонецФункции

Функция ИнициализироватьДеревоКэшаУстановленныхФлажковТребований()
	
	КэшУстановленныхФлажковТребований = Новый ДеревоЗначений;
	КэшУстановленныхФлажковТребований.Колонки.Добавить("Ссылка");
	КэшУстановленныхФлажковТребований.Колонки.Добавить("Значение");
	КэшУстановленныхФлажковТребований.Колонки.Добавить("ЭтоГруппа");
	КэшУстановленныхФлажковТребований.Колонки.Добавить("РодительТребования");
	
	Возврат КэшУстановленныхФлажковТребований;
	
КонецФункции

// Функция возвращает список вариантов проверки конфигурации.
//
Функция ПолучитьСписокВариантовПроверкиКонфигурации(Конфигурация) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ВариантыПроверки.Наименование КАК Наименование
	|ИЗ
	|	Справочник.ВариантыПроверки КАК ВариантыПроверки
	|ГДЕ
	|	ВариантыПроверки.Конфигурация = &Конфигурация
	|	И НЕ ВариантыПроверки.Наименование В (&ВариантыПроверки)
	|	И НЕ ВариантыПроверки.Предопределенный
	|УПОРЯДОЧИТЬ ПО
	|	ВариантыПроверки.Наименование";
	
	МассивВариантыПроверки = Новый Массив;
	МассивВариантыПроверки.Добавить(НСтр("ru='Текущие настройки'"));
	МассивВариантыПроверки.Добавить(НСтр("ru='<Без названия>'"));
	
	Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
	Запрос.УстановитьПараметр("ВариантыПроверки", МассивВариантыПроверки);
	
	ТаблицаВариантовПроверки = Запрос.Выполнить().Выгрузить();
	МассивВариантовПроверки = ТаблицаВариантовПроверки.ВыгрузитьКолонку("Наименование");
	
	СписокВариантовПроверки = Новый СписокЗначений;
	СписокВариантовПроверки.ЗагрузитьЗначения(МассивВариантовПроверки);
	
	Возврат СписокВариантовПроверки;
	
КонецФункции

#КонецОбласти

#Область ОтборКонфигураций

Процедура ЗаполнитьСписокВыбораКонфигурацийДляПользователя(ЭтаФорма) Экспорт
	
	ИмяПользователя = ПараметрыСеанса.ТекущийПользователь.Наименование;
	
	СписокВыбора = ЭтаФорма.ЭлементыФормы.ВыборБыстрогоОтбора.СписокВыбора;
	
	СписокВыбора.Добавить(0, НСтр("ru='Все'"));
	СписокВыбора.Добавить(1, СтрШаблон(НСтр("ru='%1 указан ответственным'"), ИмяПользователя));
	СписокВыбора.Добавить(2, СтрШаблон(НСтр("ru='%1 указан ответственным за объекты/ошибки'"), ИмяПользователя));
	
	ЭтаФорма.ВыборБыстрогоОтбора = ?(ВыбранаРольАудитор(), 0, 2);
	
КонецПроцедуры

Процедура УстановитьОтборСпискаКонфигураций(ЭтаФорма) Экспорт
	
	СправочникСписок = ЭтаФорма.СправочникСписок;
	
	СправочникСписок.Отбор.Сбросить();
	
	Если ЭтаФорма.ВыборБыстрогоОтбора = 1 Тогда
		
		СправочникСписок.Отбор.ОтветственныйЗаКонфигурацию.Использование = Истина;
		СправочникСписок.Отбор.ОтветственныйЗаКонфигурацию.ВидСравнения = ВидСравнения.Равно;
		СправочникСписок.Отбор.ОтветственныйЗаКонфигурацию.Значение = ОпределитьТекущегоПользователя();
		
	ИначеЕсли ЭтаФорма.ВыборБыстрогоОтбора = 2 Тогда
		
		СписокКонфигураций = СформироватьСписокКонфигурацийГдеПользовательОтветственныйЗаОбъектыИлиОшибки();
		
		СправочникСписок.Отбор.Ссылка.Использование = Истина;
		СправочникСписок.Отбор.Ссылка.ВидСравнения = ВидСравнения.ВСписке;
		СправочникСписок.Отбор.Ссылка.Значение = СписокКонфигураций;
		
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьСписокКонфигурацийГдеПользовательОтветственныйЗаОбъектыИлиОшибки()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	СтруктураКонфигурации.Владелец.Владелец КАК Конфигурация
	|ИЗ
	|	Справочник.СтруктураКонфигурации КАК СтруктураКонфигурации
	|ГДЕ
	|	СтруктураКонфигурации.Ответственный = &Ответственный
	|	И НЕ СтруктураКонфигурации.ПометкаУдаления
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	НайденныеОшибки.Объект.Владелец.Владелец КАК Конфигурация
	|ИЗ
	|	РегистрСведений.НайденныеОшибки КАК НайденныеОшибки
	|ГДЕ
	|	НайденныеОшибки.Ответственный = &Ответственный";
	
	Запрос.УстановитьПараметр("Ответственный", ОпределитьТекущегоПользователя());
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	СписокКонфигурация = Новый СписокЗначений;
	СписокКонфигурация.ЗагрузитьЗначения(Результат.ВыгрузитьКолонку("Конфигурация"));
	
	Возврат СписокКонфигурация;
	
КонецФункции

#КонецОбласти

#КонецОбласти
