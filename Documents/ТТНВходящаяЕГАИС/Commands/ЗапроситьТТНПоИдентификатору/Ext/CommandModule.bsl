﻿
#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ВидДокумента = ПредопределенноеЗначение("Перечисление.ВидыДокументовЕГАИС.ЗапросТТН");
	
	ИнтеграцияЕГАИСКлиент.НачатьФормированиеИсходящегоЗапроса(
		Новый ОписаниеОповещения("ФормированиеЗапросаТТН_Завершение", ЭтотОбъект),
		ВидДокумента,
		ИнтеграцияЕГАИСКлиентСервер.ПараметрыИсходящегоЗапроса(ВидДокумента));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ФормированиеЗапросаТТН_Завершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если НЕ Результат.Результат Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Запрос на загрузку ТТН сформирован.'"));
	
КонецПроцедуры

#КонецОбласти
