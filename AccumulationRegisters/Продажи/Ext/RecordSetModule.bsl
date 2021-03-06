﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

// Процедура - обработчик события ПередЗаписью набора записей.
//
Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Денормализация. Заполнение измерения "Контрагент" из измерения "Документ"
	Для Каждого Движение Из ЭтотОбъект Цикл
		Если Не ЗначениеЗаполнено(Движение.Документ) Тогда
			Продолжить;
		КонецЕсли;
		МетаданныеДокумента = Движение.Документ.Метаданные();
		Если МетаданныеДокумента.Реквизиты.Найти("Контрагент") <> Неопределено Тогда
			Движение.Контрагент = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Движение.Документ, "Контрагент");
		КонецЕсли;
	КонецЦикла;
	
	// Хозяйственная операция
	ХозяйственныеОперацииСервер.ЗаполнитьХозяйственнуюОперациюВНабореЗаписей(ЭтотОбъект);
	// Конец Хозяйственная операция
	
КонецПроцедуры // ПередЗаписью()

#КонецОбласти

#КонецЕсли