﻿
#Область СлужебныеПроцедурыИФункции

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Попытка
		СтандартнаяОбработка = Ложь;
		НаименованиеОшибки = СокрЛП(Данные.Наименование);
		ПоследнийСимволНаименования = Прав(НаименованиеОшибки, 1);
		Если СтрСравнить(ПоследнийСимволНаименования, ".") = 0 Тогда
			НаименованиеОшибки = Лев(НаименованиеОшибки, СтрДлина(НаименованиеОшибки) - 1);
		КонецЕсли;
		Представление = СтрШаблон("%1 (%2)", НаименованиеОшибки, СокрЛП(Данные.Ссылка.Код));
	Исключение
		СтандартнаяОбработка = Истина;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти
