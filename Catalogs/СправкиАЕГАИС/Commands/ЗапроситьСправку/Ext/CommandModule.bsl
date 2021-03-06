﻿
#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ВидДокумента = ПредопределенноеЗначение("Перечисление.ВидыДокументовЕГАИС.ЗапросСправкиА");
	
	ИнтеграцияЕГАИСКлиент.НачатьФормированиеИсходящегоЗапроса(
		Новый ОписаниеОповещения("ФормированиеЗапросаСправки_Завершение", ЭтотОбъект),
		ВидДокумента,
		ИнтеграцияЕГАИСКлиентСервер.ПараметрыИсходящегоЗапроса(ВидДокумента));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ФормированиеЗапросаСправки_Завершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если НЕ Результат.Результат Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Запрос на загрузку справки 1 сформирован.'"));
	
КонецПроцедуры

#КонецОбласти