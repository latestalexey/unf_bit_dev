﻿////////////////////////////////////////////////////////////////////////////////
// Подсистема "Электронная подпись в модели сервиса".
//  
////////////////////////////////////////////////////////////////////////////////


#Область ПрограммныйИнтерфейс

Процедура ИзменитьНастройкиПолученияВременныхПаролей(Сертификат, ОповещениеОЗавершении = Неопределено) Экспорт
	
	ПараметрыФормы = Новый Структура("Сертификат", Сертификат);
	ОткрытьФорму(
		"ОбщаяФорма.НастройкиПолученияВременныхПаролей",
		ПараметрыФормы,,,,,
		ОповещениеОЗавершении);
	
КонецПроцедуры

#КонецОбласти