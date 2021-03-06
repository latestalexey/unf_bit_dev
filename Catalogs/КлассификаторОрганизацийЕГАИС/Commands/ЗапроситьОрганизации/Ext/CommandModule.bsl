﻿
#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ОповещениеПриЗавершении = Новый ОписаниеОповещения("ФормированиеЗапросаКлассификатора_Завершение", ЭтотОбъект);
	
	ВидДокумента = ПредопределенноеЗначение("Перечисление.ВидыДокументовЕГАИС.ЗапросОрганизаций");
	ИнтеграцияЕГАИСКлиент.НачатьФормированиеИсходящегоЗапроса(
		ОповещениеПриЗавершении,
		ВидДокумента,
		ИнтеграцияЕГАИСКлиентСервер.ПараметрыИсходящегоЗапроса(ВидДокумента));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ФормированиеЗапросаКлассификатора_Завершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если НЕ Результат.Результат Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Запрос на загрузку классификатора сформирован.'"));
	
КонецПроцедуры

#КонецОбласти