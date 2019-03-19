// Copyright 2016 xDrivenDevelopment
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#Использовать cmdline
#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать v8runner
#Использовать strings
#Использовать gitrunner

Перем Лог;
Перем КодВозврата;
Перем мВозможныеКоманды;
Перем ЭтоWindows;
Перем ИспользоватьКонфигуратор;
Перем КонтекстКонфигуратора;
Перем ГитРепозиторий;

Функция Версия() Экспорт

	Версия = "2.2.1";

	Возврат "v" + Версия;

КонецФункции

Функция ВозможныеКоманды()

	Если мВозможныеКоманды = Неопределено Тогда
		мВозможныеКоманды = Новый Структура;
		мВозможныеКоманды.Вставить("Декомпилировать", "--decompile");
		мВозможныеКоманды.Вставить("Помощь", "--help");
		мВозможныеКоманды.Вставить("ПроверитьКонфигГит", "--git-check-config");
		мВозможныеКоманды.Вставить("ОбработатьИзмененияИзГит", "--git-precommit");
		мВозможныеКоманды.Вставить("Компилировать", "--compile");
		мВозможныеКоманды.Вставить("Установить", "--install");
	КонецЕсли;

	Возврат мВозможныеКоманды;

КонецФункции

Функция ЗапускВКоманднойСтроке()

	КодВозврата = 0;

	Если ТекущийСценарий().Источник <> СтартовыйСценарий().Источник Тогда
		Возврат Ложь;
	КонецЕсли;

	Лог.Информация("precommit1c " + Версия() + Символы.ПС);

	Попытка

		Парсер = Новый ПарсерАргументовКоманднойСтроки();

		ДобавитьОбщиеПараметры(Парсер);
		ДобавитьОписаниеКомандыДекомпилировать(Парсер);
		ДобавитьОписаниеКомандыПомощь(Парсер);
		ДобавитьОписаниеКомандыПроверитьКонфигГит(Парсер);
		ДобавитьОписаниеКомандыИзмененияПоЖурналуГит(Парсер);
		ДобавитьОписаниеКомандыКомпилировать(Парсер);
		ДобавитьОписаниеКомандыУстановить(Парсер);

		Аргументы = Парсер.РазобратьКоманду(АргументыКоманднойСтроки);
		Лог.Отладка("ТипЗнч(Аргументы)= "+ТипЗнч(Аргументы));
		Если Аргументы = Неопределено Тогда
			ВывестиСправку();
			Возврат Истина;
		КонецЕсли;

		Команда = Аргументы.Команда;
		Лог.Отладка("Передана команда: "+Команда);
		Для Каждого Параметр Из Аргументы.ЗначенияПараметров Цикл
			Лог.Отладка("%1 = %2", Параметр.Ключ, Параметр.Значение);
		КонецЦикла;

		ИспользоватьКонфигуратор = Аргументы.ЗначенияПараметров["--use-designer"];

		Если НЕ ПустаяСтрока(Аргументы.ЗначенияПараметров["--ib-connection-string"]) Тогда
			Конфигуратор = Новый УправлениеКонфигуратором();
			КонтекстКонфигуратора = Конфигуратор.ПолучитьКонтекст();
			КонтекстКонфигуратора.КлючСоединенияСБазой = Аргументы.ЗначенияПараметров["--ib-connection-string"];
			КонтекстКонфигуратора.ИмяПользователя = Аргументы.ЗначенияПараметров["--ib-user"];
			КонтекстКонфигуратора.Пароль = Аргументы.ЗначенияПараметров["--ib-pwd"];
		Иначе
			КонтекстКонфигуратора = Неопределено;
		КонецЕсли;

		Если Команда = ВозможныеКоманды().Декомпилировать Тогда
			Декомпилировать(
				Аргументы.ЗначенияПараметров["ПутьВходящихДанных"],
				Аргументы.ЗначенияПараметров["ВыходнойКаталог"]
			);
		ИначеЕсли Команда = ВозможныеКоманды().Помощь Тогда
			ВывестиСправку();
		ИначеЕсли Команда = ВозможныеКоманды().ПроверитьКонфигГит Тогда
			ПроверитьНастройкиРепозитарияГит();
		ИначеЕсли Команда = ВозможныеКоманды().ОбработатьИзмененияИзГит Тогда
			ОбработатьИзмененияИзГит(
				Аргументы.ЗначенияПараметров["ВыходнойКаталог"],
				Аргументы.ЗначенияПараметров["--remove-orig-bin-files"]
			);
		ИначеЕсли Команда = ВозможныеКоманды().Компилировать Тогда
			Компилировать(
				Аргументы.ЗначенияПараметров["ПутьВходящихДанных"],
				Аргументы.ЗначенияПараметров["ВыходнойКаталог"],
				Аргументы.ЗначенияПараметров["--recursive"]
			);
		ИначеЕсли Команда = ВозможныеКоманды().Установить Тогда
			УстановитьВКаталог(ТекущийКаталог());
		КонецЕсли;

	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		КодВозврата = 1;
	КонецПопытки;

	Лог.Отладка("Очищаем каталог временной ИБ");
	Попытка
		ВременныеФайлы.Удалить();
	Исключение
	КонецПопытки;

	Возврат Истина;

КонецФункции

Процедура ДобавитьОбщиеПараметры(Знач Парсер)
	Парсер.ДобавитьИменованныйПараметр("--ib-connection-string", "Строка подключения к БД", Истина);
	Парсер.ДобавитьИменованныйПараметр("--ib-user", "Пользователь БД", Истина);
	Парсер.ДобавитьИменованныйПараметр("--ib-pwd", "Пароль БД", Истина);
	Парсер.ДобавитьПараметрФлаг("--use-designer", "", Истина);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыДекомпилировать(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Декомпилировать);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьВходящихДанных");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ВыходнойКаталог");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыПомощь(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Помощь);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыПроверитьКонфигГит(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().ПроверитьКонфигГит);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыИзмененияПоЖурналуГит(Знач Парсер)

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().ОбработатьИзмененияИзГит);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ВыходнойКаталог");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--remove-orig-bin-files");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Процедура ДобавитьОписаниеКомандыКомпилировать(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Компилировать);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьВходящихДанных");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ВыходнойКаталог");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--recursive");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыУстановить(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Установить);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура Инициализация()
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

	Лог = Логирование.ПолучитьЛог("oscript.app.v8files-extractor");
	Лог.Закрыть();
	//Лог.УстановитьУровень(УровниЛога.Отладка);

	ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
	Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);

	ИспользоватьКонфигуратор = Ложь;
	КонтекстКонфигуратора = Неопределено;

	ГитРепозиторий = Новый ГитРепозиторий();
	ГитРепозиторий.УстановитьРабочийКаталог(ТекущийКаталог());

	Попытка

		Лог_cmdline = Логирование.ПолучитьЛог("oscript.lib.cmdline");
		Лог_cmdline.Закрыть();

		ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
		Лог_cmdline.ДобавитьСпособВывода(ВыводПоУмолчанию);

		Аппендер = Новый ВыводЛогаВФайл();
		Аппендер.ОткрытьФайл(ОбъединитьПути(КаталогПроекта(), ИмяСкрипта()+".cmdline.log"));
		Лог_cmdline.ДобавитьСпособВывода(Аппендер);

		Аппендер = Новый ВыводЛогаВФайл();
		Аппендер.ОткрытьФайл(ОбъединитьПути(КаталогПроекта(), ИмяСкрипта()+".log"));
		Лог.ДобавитьСпособВывода(Аппендер);
	Исключение
		// Если прекоммит установлен, как приложение, в Program Files
		// То команда не сможет отработать из за отсутствия прав на запись.
		// Но нам в данном случае и не нужен лог в файле.
	КонецПопытки;
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////
// РЕАЛИЗАЦИЯ КОМАНД

Процедура Декомпилировать(Знач Путь, Знач КаталогВыгрузки) Экспорт
	Файл = Новый Файл(Путь);
	Если Файл.ЭтоКаталог() Тогда
		РазобратьКаталог(Файл, КаталогВыгрузки, Файл.ПолноеИмя);
	Иначе
		РазобратьФайл(Файл, КаталогВыгрузки, Файл.Путь);
	КонецЕсли;
КонецПроцедуры

Процедура РазобратьКаталог(Знач ОбъектКаталога, Знач КаталогВыгрузки, Знач КаталогКорень) Экспорт
	ПутьКаталога = ОбъектКаталога.ПолноеИмя;

	ОтносительныйПутьКаталога = ПолучитьОтносительныйПутьФайла(КаталогКорень, ПутьКаталога);
	ОтносительныйПутьКаталога = ?(ПустаяСтрока(ОтносительныйПутьКаталога), ПутьКаталога, ОтносительныйПутьКаталога);
	Лог.Информация("Подготовка выгрузки каталога %1 в каталог %2, корень %3", ОтносительныйПутьКаталога, КаталогВыгрузки, КаталогКорень);

	ИмяКаталогаВыгрузки = Новый Файл(КаталогВыгрузки).Имя;

	Файлы = НайтиФайлы(ПутьКаталога, ПолучитьМаскуВсеФайлы());
	Для Каждого Файл из Файлы Цикл
		Если Файл.ЭтоКаталог() Тогда

			РазобратьКаталог(Новый Файл(Файл.ПолноеИмя), КаталогВыгрузки, КаталогКорень);

		ИначеЕсли ТипФайлаПоддерживается(Файл) Тогда
			Лог.Информация("Подготовка выгрузки файла %1 в каталог %2", Файл.Имя, ИмяКаталогаВыгрузки);

			РазобратьФайлВнутр(Файл, КаталогВыгрузки, КаталогКорень);

			Лог.Информация("Завершена выгрузка файла %1 в каталог %2", Файл.Имя, ИмяКаталогаВыгрузки);
		КонецЕсли;
	КонецЦикла;

	Лог.Информация("Завершена выгрузка каталога %1 в каталог %2, корень %3", ОтносительныйПутьКаталога, КаталогВыгрузки, КаталогКорень);
КонецПроцедуры

Функция РазобратьФайл(Знач Файл, Знач КаталогВыгрузки, Знач КаталогКорень = "") Экспорт
	ПутьФайла = Файл.ПолноеИмя;
	Лог.Информация("Проверка необходимости выгрузки файла %1 в каталог %2, корень %3", ПутьФайла, КаталогВыгрузки, КаталогКорень);

	КаталогИсходников = РазобратьФайлВнутр(Файл, КаталогВыгрузки, КаталогКорень);

	Лог.Информация("Завершена проверка необходимости выгрузки файла %1 в каталог %2, корень %3", ПутьФайла, КаталогВыгрузки, КаталогКорень);

	Возврат КаталогИсходников;

КонецФункции

Функция ТипФайлаПоддерживается(Файл)
	Если ПустаяСтрока(Файл.Расширение) Тогда
		Возврат Ложь;
	КонецЕсли;

	Поз = Найти(ВРег(".epf,.erf,.cfe,.mxl,"), ВРег(Файл.Расширение+","));
	Возврат Поз > 0;

КонецФункции

Функция РазобратьФайлВнутр(Знач Файл, Знач КаталогВыгрузки, Знач КаталогКорень)

	ПутьФайла = Файл.ПолноеИмя;
	Если Не ТипФайлаПоддерживается(Файл) Тогда
		ВызватьИсключение "Тип файла """+Файл.Расширение+""" не поддерживается";
	КонецЕсли;

	Ожидаем.Что(Файл.Существует(), "Файл " + ПутьФайла + " должен существовать").ЭтоИстина();

	ОтносительныйПутьКаталогаФайла = ПолучитьОтносительныйПутьФайла(КаталогКорень, ОбъединитьПути(Файл.Путь, Файл.ИмяБезРасширения));
	Лог.Отладка("ОтносительныйПутьКаталогаФайла <%1>", ОтносительныйПутьКаталогаФайла);

	ПутьКаталогаИсходников = ОбъединитьПути(КаталогВыгрузки, ОтносительныйПутьКаталогаФайла);
	Лог.Отладка("ПутьКаталогаИсходников <%1>", ПутьКаталогаИсходников);
	ПапкаИсходников = Новый Файл(ПутьКаталогаИсходников);

	Если НЕ ВРег(Файл.Расширение) = ".MXL" Тогда
		ОбеспечитьПустойКаталог(ПапкаИсходников);
	КонецЕсли;

	Если ВРег(Файл.Расширение) = ".CFE" Тогда
		ЗапуститьРаспаковкуРасширения(Файл, ПапкаИсходников);
	Иначе
		ЗапуститьРаспаковкуОбработки(Файл, ПапкаИсходников);
	КонецЕсли;

	Возврат ПапкаИсходников.ПолноеИмя;

КонецФункции

Функция ПолучитьОтносительныйПутьФайла(КаталогКорень, ВнутреннийКаталог)
	Если ПустаяСтрока(КаталогКорень) Тогда
		Возврат "";
	КонецЕсли;

	ФайлКорень = Новый Файл(КаталогКорень);
	ФайлВнутреннийКаталог = Новый Файл(ВнутреннийКаталог);
	Рез = СтрЗаменить(ФайлВнутреннийКаталог.ПолноеИмя, ФайлКорень.ПолноеИмя, "");
	Если Лев(Рез, 1) = "\" Тогда
		Рез = Сред(Рез, 2);
	КонецЕсли;
	Если Прав(Рез, 1) = "\" Тогда
		Рез = Лев(Рез, СтрДлина(Рез)-1);
	КонецЕсли;
	Возврат Рез;
КонецФункции

Процедура ЗапуститьРаспаковкуРасширения(Знач Файл, Знач ПапкаИсходников)

	Лог.Отладка("Запускаем распаковку файла расширения");

	Конфигуратор = Новый УправлениеКонфигуратором();
	Если КонтекстКонфигуратора = Неопределено Тогда
		КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
		Конфигуратор.КаталогСборки(КаталогВременнойИБ);
	Иначе
		Конфигуратор.ИспользоватьКонтекст(КонтекстКонфигуратора);
	КонецЕсли;

	УстановитьУровеньЛогаКонфигуратораРавнымУровнюПродукта();

	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();

	ИмяРасширения = Файл.ИмяБезРасширения;
	Лог.Отладка("Загрузка расширения '%1'", ИмяРасширения);
	Параметры.Добавить("/LoadCfg """ + Файл.ПолноеИмя + """");
	Параметры.Добавить("-Extension """ + ИмяРасширения + """");
	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());

	Лог.Отладка("Разбор расширения '%1' в исходники в каталог '%2'", ИмяРасширения, ПапкаИсходников.ПолноеИмя);
	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();

	Параметры.Добавить("/DumpConfigToFiles """ + ПапкаИсходников.ПолноеИмя + """");
	Параметры.Добавить("-Extension """ + ИмяРасширения + """");
	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());

КонецПроцедуры

Процедура ЗапуститьРаспаковкуОбработки(Знач Файл, Знач ПапкаИсходников)

	Лог.Отладка("Запускаем распаковку файла");

	Конфигуратор = Новый УправлениеКонфигуратором();
	Если КонтекстКонфигуратора = Неопределено Тогда
		КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
		Конфигуратор.КаталогСборки(КаталогВременнойИБ);
	Иначе
		Конфигуратор.ИспользоватьКонтекст(КонтекстКонфигуратора);
	КонецЕсли;

	ЛогКонфигуратора = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	ЛогКонфигуратора.УстановитьУровень(Лог.Уровень());


	ЭтоМакет = ВРег(Файл.Расширение) = ".MXL";

	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
	Если НЕ ЭтоМакет И ИспользоватьКонфигуратор Тогда

		КоманднаяСтрокаРаспаковки = СтрШаблон("/DumpExternalDataProcessorOrReportToFiles ""%1\%2.xml"" ""%3""", ПапкаИсходников.ПолноеИмя, Файл.ИмяБезРасширения, Файл.ПолноеИмя);

		Лог.Отладка("Командная строка распаковки: " + КоманднаяСтрокаРаспаковки);

		Параметры.Добавить(КоманднаяСтрокаРаспаковки);

	Иначе

		Параметры[0] = "ENTERPRISE";

		ПутьV8Reader = ОбъединитьПути(ТекущийСценарий().Каталог, "v8Reader", "V8Reader.epf");
		Лог.Отладка("Путь к V8Reader: " + ПутьV8Reader);
		Ожидаем.Что(Новый Файл(ПутьV8Reader).Существует(), "Некорректно установлен V8Reader. Не обнаружен файл <" + ПутьV8Reader + ">").ЭтоИстина();

		КоманднаяСтрокаV8Reader = СтрШаблон("/C""decompile;pathtocf;%1;pathout;%2;convert-mxl2txt;ЗавершитьРаботуПосле;""", Файл.ПолноеИмя, ?(ЭтоМакет, Файл.Путь, ПапкаИсходников.ПолноеИмя));

		Лог.Отладка("Командная строка V8Reader: " + КоманднаяСтрокаV8Reader);

		Параметры.Добавить("/RunModeOrdinaryApplication");
		Параметры.Добавить("/Execute """ + ПутьV8Reader + """");
		Параметры.Добавить(КоманднаяСтрокаV8Reader);

	КонецЕсли;

	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());

КонецПроцедуры

Процедура УстановитьУровеньЛогаКонфигуратораРавнымУровнюПродукта()
	ЛогКонфигуратора = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	ЛогКонфигуратора.УстановитьУровень(Лог.Уровень());
	ЛогКонфигуратора.Закрыть();
КонецПроцедуры

Процедура УстановитьВКаталог(Знач Каталог) Экспорт

	Если Не ГитРепозиторий.ЭтоРепозиторий() Тогда
		ВызватьИсключение "Каталог не является репозиторием GIT";
	КонецЕсли;

	КаталогПрекоммита = ТекущийСценарий().Каталог;
	КаталогХуков = ОбъединитьПути(Каталог, ".git", "hooks");
	ОбеспечитьКаталог(КаталогХуков);

	КопироватьВКаталог(КаталогПрекоммита, КаталогХуков, "pre-commit");
	КопироватьВКаталог(КаталогПрекоммита, КаталогХуков, "v8Reader");
	КопироватьВКаталог(КаталогПрекоммита, КаталогХуков, "v8files-extractor.os");
	КопироватьВКаталог(КаталогПрекоммита, КаталогХуков, "tools");

	Если ИспользоватьКонфигуратор Или НЕ КонтекстКонфигуратора = Неопределено Тогда
		ДополнитьФайлХукаДаннымиПодключения(КаталогХуков);
	КонецЕсли;

	ГитРепозиторий.УстановитьНастройку("core.quotePath", "false", РежимУстановкиНастроекGit.Локально);
	ГитРепозиторий.УстановитьНастройку("core.longpaths", "true", РежимУстановкиНастроекGit.Локально);

	Лог.Информация("Установка завершена");

КонецПроцедуры

Процедура ДополнитьФайлХукаДаннымиПодключения(КаталогХуков)
	СтрокаПараметровПодключения = ?(ИспользоватьКонфигуратор, " --use-designer", "");
	ДополнитьСтрокуПараметровПодключения(СтрокаПараметровПодключения, КонтекстКонфигуратора.КлючСоединенияСБазой, "--ib-connection-string");
	ДополнитьСтрокуПараметровПодключения(СтрокаПараметровПодключения, КонтекстКонфигуратора.ИмяПользователя, "--ib-user");
	ДополнитьСтрокуПараметровПодключения(СтрокаПараметровПодключения, КонтекстКонфигуратора.Пароль, "--ib-pwd");
	СтрокаПоиска = "oscript -encoding=utf-8 .git/hooks/v8files-extractor.os --git-precommit src";
	СтрокаЗамены = СтрШаблон("%1%2", СтрокаПоиска, СтрокаПараметровПодключения);
	ЗаменитьСтрокуВФайле(ОбъединитьПути(КаталогХуков, "pre-commit"), СтрокаПоиска, СтрокаЗамены)
КонецПроцедуры

Процедура ДополнитьСтрокуПараметровПодключения(СтрокаПараметровПодключения, Знач ЗначениеПараметра, Знач ИмяПараметра)
	Если ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		СтрокаПараметровПодключения = СтрШаблон("%1 %2 %3", СтрокаПараметровПодключения, ИмяПараметра, ЗначениеПараметра);
	КонецЕсли;
КонецПроцедуры

Процедура ЗаменитьСтрокуВФайле(Знач ПутьФайла, Знач СтрокаПоиска, Знач СтрокаЗамены) Экспорт
	Чтение = Новый ЧтениеТекста(ПутьФайла, КодировкаТекста.UTF8NoBOM);
	Текст = Чтение.Прочитать();
	Чтение.Закрыть();
	Если СтрНайти(Текст, "--ib-connection-string") = 0 Тогда
		Текст = СтрЗаменить(Текст, СтрокаПоиска, СтрокаЗамены);
		Запись = Новый ЗаписьТекста(ПутьФайла, КодировкаТекста.UTF8NoBOM);
		Запись.Записать(Текст);
		Запись.Закрыть();
	Иначе
		Лог.Предупреждение("В хуке уже прописана сервисная база!");
	КонецЕсли;
КонецПроцедуры

Процедура КопироватьВКаталог(Знач КаталогИсточник, Знач КаталогПриемник, Знач ОбъектКопирования)

	Лог.Информация("Копирую: " + ОбъектКопирования);
	ФайлИсточник = Новый Файл(ОбъединитьПути(КаталогИсточник, ОбъектКопирования));
	ФайлПриемник = Новый Файл(ОбъединитьПути(КаталогПриемник, ОбъектКопирования));
	Если ФайлИсточник.ЭтоКаталог() Тогда
		КопироватьСодержимоеКаталога(ФайлИсточник.ПолноеИмя, ФайлПриемник.ПолноеИмя);
	Иначе
		КопироватьФайл(ФайлИсточник.ПолноеИмя, ФайлПриемник.ПолноеИмя);
	КонецЕсли;

КонецПроцедуры

Процедура ОбеспечитьПустойКаталог(Знач ФайлОбъектКаталога)

	Если Не ФайлОбъектКаталога.Существует() Тогда
		Лог.Отладка("Создаем новый каталог " + ФайлОбъектКаталога.ПолноеИмя);
		СоздатьКаталог(ФайлОбъектКаталога.ПолноеИмя);
	ИначеЕсли ФайлОбъектКаталога.ЭтоКаталог() Тогда
		Лог.Отладка("Очищаем каталог " + ФайлОбъектКаталога.ПолноеИмя);
		УдалитьФайлы(ФайлОбъектКаталога.ПолноеИмя, ПолучитьМаскуВсеФайлы());
	Иначе
		ВызватьИсключение "Путь " + ФайлОбъектКаталога.ПолноеИмя + " не является каталогом. Выгрузка невозможна";
	КонецЕсли;

КонецПроцедуры

Процедура ОбеспечитьКаталог(Знач Путь)

	ФайлОбъектКаталога = Новый Файл(Путь);
	Если Не ФайлОбъектКаталога.Существует() Тогда
		Лог.Отладка("Создаем новый каталог " + ФайлОбъектКаталога.ПолноеИмя);
		СоздатьКаталог(ФайлОбъектКаталога.ПолноеИмя);
	ИначеЕсли Не ФайлОбъектКаталога.ЭтоКаталог() Тогда
		ВызватьИсключение "Путь " + ФайлОбъектКаталога.ПолноеИмя + " не является каталогом. Выгрузка невозможна";
	КонецЕсли;

КонецПроцедуры


Процедура ВывестиСправку()
	Сообщить("Утилита сборки/разборки внешних файлов 1С");
	Сообщить(Версия());
	Сообщить(" ");
	Сообщить("Параметры командной строки:");
	Сообщить("	--decompile inputPath outputPath");
	Сообщить("		Разбор файлов на исходники");

	Сообщить("	--help");
	Сообщить("		Показ этого экрана");
	Сообщить("	--git-check-config");
	Сообщить("		Проверка настроек репозитория git");
	Сообщить("	--git-precommit outputPath [--remove-orig-bin-files]");
	Сообщить("		Запустить чтение индекса из git и определить список файлов для разбора, разложить их и добавить исходники в индекс");
	Сообщить("		Если передан флаг --remove-orig-bin-files, обработанные файлы epf/ert будут удалены из индекса git");
	Сообщить("	--compile inputPath outputPath [--recursive]");
	Сообщить("		Собрать внешний файл/обработку.");
	Сообщить("		Если указан параметр --recursive, скрипт будет рекурсивно искать исходные коды отчетов и обработок в указанном каталоге и собирать их, повторяя структуру каталога");
	Сообщить("	--install");
	Сообщить("		Установить precommit1c для текущего репозитория git");
	Сообщить(" ");
	Сообщить("Общие параметры:");
	Сообщить("	--use-designer");
	Сообщить("		Если передан этот флаг, то для операций сборки/разборки будет использован конфигуратор 1С.");
	Сообщить("		ТОЛЬКО ДЛЯ ВЕРСИЙ ПЛАТФОРМЫ 8.3.8 И ВЫШЕ!");
	Сообщить("	--ib-connection-string");
	Сообщить("		Строка подключения к информационной базе");
	Сообщить("	--ib-user");
	Сообщить("		Имя пользователя в информационной базе");
	Сообщить("	--ib-pwd");
	Сообщить("		Пароль пользователя в информационной базе");
КонецПроцедуры


Процедура ОбработатьИзмененияИзГит(Знач ВыходнойКаталог, Знач УдалятьФайлыИзИндексаГит) Экспорт

	Если ПустаяСтрока(ВыходнойКаталог) Тогда
		ВыходнойКаталог = "src";
	КонецЕсли;
	КореньРепо = ТекущийКаталог();
	Лог.Отладка("Текущий каталог " + КореньРепо);
	Лог.Отладка("Каталог выгрузки " + ВыходнойКаталог);

	ПроверитьНастройкиРепозитарияГит();

	ЖурналИзмененийГитСтрокой = ПолучитьЖурналИзмененийГит();
	ИменаФайлов = ПолучитьИменаИзЖурналаИзмененийГит(ЖурналИзмененийГитСтрокой);

	КаталогИсходников = ОбъединитьПути(КореньРепо, ВыходнойКаталог);
	СписокНовыхКаталогов = Новый Массив;
	Для Каждого ИмяФайла Из ИменаФайлов Цикл
		Лог.Отладка("Изучаю файл из журнала git " + ИмяФайла);
		ОбработанныйПуть = УбратьКавычкиВокругПути(ИмяФайла);
		ПолныйПуть = ОбъединитьПути(КореньРепо, ОбработанныйПуть);
		Файл = Новый Файл(ПолныйПуть);
		Если ТипФайлаПоддерживается(Файл) Тогда
			Лог.Отладка("Получен из журнала git файл " + Файл);
			СписокНовыхКаталогов.Добавить(РазобратьФайл(Файл, КаталогИсходников, КореньРепо));
			Если УдалятьФайлыИзИндексаГит Тогда
				УдалитьФайлИзИндексаГит(ПолныйПуть);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	ДобавитьИсходникиВГит(СписокНовыхКаталогов);

КонецПроцедуры

Процедура УдалитьФайлИзИндексаГит(Знач ПолныйПуть)
	Лог.Отладка("Удаляю файл из индекса");
	ПараметрыКоманды = Новый Массив;
	ПараметрыКоманды.Добавить("rm");
	ПараметрыКоманды.Добавить("--cached");
	ПараметрыКоманды.Добавить(ОбернутьПутьВКавычки(ПолныйПуть));
	ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);
КонецПроцедуры

Процедура ПроверитьНастройкиРепозитарияГит() Экспорт
	ПроверитьНастройкуРепозитарияГит("core.quotepath", "false");
	ПроверитьНастройкуРепозитарияГит("core.longpaths", "true");
КонецПроцедуры

Процедура ПроверитьНастройкуРепозитарияГит(Настройка, ПравильноеЗначение)
	Перем КодВозврата;

	Лог.Отладка("Выполняю проверку настройки %1", Настройка);
	ЗначениеНастройки = ГитРепозиторий.ПолучитьНастройку(Настройка);
	Если ЗначениеНастройки = ПравильноеЗначение Тогда
		Возврат;
	КонецЕсли;

	ВызватьИсключение СтрШаблон("У текущего репозитария не заданы необходимые настройки!
	|Выполните команду git config --local %1 %2
	|
	|А еще лучше сделать глобальную настройку git config --global %1 %2", Настройка, ПравильноеЗначение);

КонецПроцедуры


Функция ПолучитьЖурналИзмененийГит()

	Перем КодВозврата;
	Попытка
		ПараметрыКоманды = СтрРазделить("diff-index --name-status --cached HEAD", " ");
		ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);
		Вывод = ГитРепозиторий.ПолучитьВыводКоманды();
	Исключение
		ПараметрыКоманды = СтрРазделить("status --porcelain", " ");
		ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);
		Вывод = ГитРепозиторий.ПолучитьВыводКоманды();
	КонецПопытки;

	Возврат Вывод;

КонецФункции

Функция ПолучитьВыводПроцесса(Знач КоманднаяСтрока, КодВозврата)

	// // Это для dev версии 1.0.11
	// Процесс = СоздатьПроцесс(КоманднаяСтрока, , Истина,, КодировкаТекста.UTF8);
	// Процесс.Запустить();
	// Вывод = "";

	// Процесс.ОжидатьЗавершения();

	// Вывод = Вывод + Процесс.ПотокВывода.Прочитать();
	// Вывод = Вывод + Процесс.ПотокОшибок.Прочитать();

	// КодВозврата = Процесс.КодВозврата;

	ЛогФайл = ВременныеФайлы.НовоеИмяФайла();
	СтрокаЗапуска = "cmd /C """ + КоманднаяСтрока + " > """ + ЛогФайл + """ 2>&1""";
	Лог.Отладка(СтрокаЗапуска);
	ЗапуститьПриложение(СтрокаЗапуска,, Истина, КодВозврата);
	Лог.Отладка("Код возврата: " + КодВозврата);
	ЧтениеТекста = Новый ЧтениеТекста(ЛогФайл, "utf-8");
	Вывод = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	Возврат Вывод;

КонецФункции

Функция ПолучитьИменаИзЖурналаИзмененийГит(Знач ЖурналИзмененийГит) Экспорт
	Лог.Отладка("ЖурналИзмененийГит:");
	МассивИмен = Новый Массив;
	// Если Найти(ЖурналИзмененийГит, Символы.ПС) > 0 Тогда
		МассивСтрокЖурнала = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ЖурналИзмененийГит, Символы.ПС);
	// Иначе
		// ЖурналИзмененийГит = СтрЗаменить(ЖурналИзмененийГит, "A"+Символ(0), "A"+" ");
		// ЖурналИзмененийГит = СтрЗаменить(ЖурналИзмененийГит, "M"+Символ(0), "M"+" ");
		// ЖурналИзмененийГит = СтрЗаменить(ЖурналИзмененийГит, Символ(0), Символы.ПС);
		// МассивСтрокЖурнала = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ЖурналИзмененийГит, Символы.ПС); //Символ(0));
	// КонецЕсли;

	Для Каждого СтрокаЖурнала Из МассивСтрокЖурнала Цикл
		Лог.Отладка("	<%1>", СтрокаЖурнала);
		СтрокаЖурнала = СокрЛ(СтрокаЖурнала);
		СимволИзменений = Лев(СтрокаЖурнала, 1);
		Если СимволИзменений = "A" или СимволИзменений = "M" Тогда
			ИмяФайла = СокрЛП(Сред(СтрокаЖурнала, 2));
			// ИмяФайла = СтрЗаменить(ИмяФайла, Символ(0), "");
			МассивИмен.Добавить(ИмяФайла);
			Лог.Отладка("		В журнале git найдено имя файла <%1>", ИмяФайла);
		КонецЕсли;
	КонецЦикла;
	Возврат МассивИмен;
КонецФункции

Процедура ДобавитьИсходникиВГит(Знач СписокНовыхКаталогов)

	Перем КодВозврата;

	Для Каждого Каталог Из СписокНовыхКаталогов Цикл

		Лог.Отладка("Запуск git add для каталога " + Каталог);
		ПараметрыКоманды = Новый Массив;
		ПараметрыКоманды.Добавить("add");
		ПараметрыКоманды.Добавить("--all");
		ПараметрыКоманды.Добавить(ОбернутьПутьВКавычки(Каталог));
		ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);

	КонецЦикла

КонецПроцедуры

Процедура Компилировать(Знач Путь, Знач КаталогВыгрузки, Знач Рекурсивно = Ложь) Экспорт

	ПутьКИсходникам = ОбъединитьПути(ТекущийКаталог(), Путь);

	ПапкаИсходников = Новый Файл(ПутьКИсходникам);

	Ожидаем.Что(ПапкаИсходников.Существует(), "Папка " + ПутьКИсходникам + " должна существовать").ЭтоИстина();
	Ожидаем.Что(ПапкаИсходников.ЭтоКаталог(), "Путь " + ПутьКИсходникам + "должен быть каталогом").ЭтоИстина();

	Если Рекурсивно Тогда
		СобратьКаталог(ПутьКИсходникам, КаталогВыгрузки);
	Иначе
		СобратьФайл(ПутьКИсходникам, КаталогВыгрузки);
	КонецЕсли;

КонецПроцедуры

Процедура СобратьКаталог(Знач ПутьКИсходникам, КаталогВыгрузки)

	СписокФайловВКаталоге = НайтиФайлы(ПутьКИсходникам, ПолучитьМаскуВсеФайлы());

	Если НЕ Новый Файл(КаталогВыгрузки).Существует() Тогда
		СоздатьКаталог(КаталогВыгрузки);
	КонецЕсли;

	Для Каждого Файл Из СписокФайловВКаталоге Цикл

		Если НЕ Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;

		Если ЭтоПутьКИсходнымКодамОбработок(Файл) Тогда
			СобратьФайл(Файл.ПолноеИмя, КаталогВыгрузки);
		Иначе
			НовыйПутьВыгрузки = ОбъединитьПути(КаталогВыгрузки, Файл.Имя);
			СобратьКаталог(Файл.ПолноеИмя, НовыйПутьВыгрузки);
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Функция СобратьФайл(Знач ПутьКИсходникам, Знач КаталогВыгрузки)

	Лог.Информация("Собираю исходники <%1>", ПутьКИсходникам);

	ПапкаИсходников = Новый Файл(ПутьКИсходникам);
	ИмяПапки = ПапкаИсходников.Имя;

	Если ИспользоватьКонфигуратор Тогда

		ПутьСборки = ОбъединитьПути(ПутьКИсходникам, ИмяПапки + ".xml");
		//Платформа сама подставит нужное расширение при сборке
		ИмяФайлаОбъекта = ОбъединитьПути(ТекущийКаталог(), КаталогВыгрузки, ИмяПапки);

	Иначе

		Переименования = ПолучитьСоответствиеПереименований(ПутьКИсходникам);

		ПутьСборки = ВременныеФайлы.СоздатьКаталог();
		Лог.Информация("Восстанавливаю структуру исходников в <" + ПутьСборки + ">");

		Для Каждого Переименование Из Переименования Цикл

			НовыйПуть = ОбъединитьПути(ПутьСборки, Переименование.Ключ);
			НовыйКаталог = Новый Файл(НовыйПуть);
			ПутьДоНовогоКаталога = НовыйКаталог.Путь;
			Если НЕ Новый Файл(ПутьДоНовогоКаталога).Существует() Тогда
				СоздатьКаталог(ПутьДоНовогоКаталога);
			КонецЕсли;

			СтарыйПуть = ОбъединитьПути(ПутьКИсходникам, Переименование.Значение);
			СтарыйКаталог = Новый Файл(СтарыйПуть);
			Если СтарыйКаталог.ЭтоКаталог() Тогда
				КопироватьСодержимоеКаталога(СтарыйПуть, НовыйПуть);
				Если ЭтоПутьКТолстойФорме(НовыйПуть) Тогда
					ПереместитьФайл(ОбъединитьПути(НовыйПуть, "module.bsl"), ОбъединитьПути(НовыйПуть, "module"));
				КонецЕсли;
			Иначе
				КопироватьФайл(СтарыйПуть, НовыйПуть);
			КонецЕсли;

		КонецЦикла;

		ТипФайла = ПолучитьТипФайлаПоКаталогуИсходников(ПутьСборки);

		ИмяФайлаОбъекта = ОбъединитьПути(ТекущийКаталог(), КаталогВыгрузки, ИмяПапки + "." + ТипФайла);

	КонецЕсли;

	СобратьФайлИзИсходников(ПутьСборки, ИмяФайлаОбъекта);
	Лог.Информация("Успешно собран файл "+ИмяФайлаОбъекта);

	Возврат ИмяФайлаОбъекта;

КонецФункции

Функция ЭтоПутьКИсходнымКодамОбработок(ПапкаИсходников)

	Если ИспользоватьКонфигуратор Тогда
		ПутьКФайлу = ОбъединитьПути(ПапкаИсходников.ПолноеИмя, ПапкаИсходников.Имя + ".xml");
	Иначе
		ПутьКФайлу = ОбъединитьПути(ПапкаИсходников.ПолноеИмя, "renames.txt");
	КонецЕсли;

	Возврат Новый Файл(ПутьКФайлу).Существует();

КонецФункции

Функция ЭтоПутьКТолстойФорме(ПутьКПапке)

	ФайлМодуля = Новый Файл(ОбъединитьПути(ПутьКПапке, "module.bsl"));
	ФайлФормы  = Новый Файл(ОбъединитьПути(ПутьКПапке, "form"));

	Возврат ФайлМодуля.Существует() И ФайлФормы.Существует();

КонецФункции

Функция ПолучитьТипФайлаПоКаталогуИсходников(Знач КаталогИсходников)

	ПутьКФайлуРут = ОбъединитьПути(КаталогИсходников, "root");
	ФайлРут = Новый Файл(ПутьКФайлуРут);

	Ожидаем.Что(ФайлРут.Существует(), "Файл <" + ПутьКФайлуРут +  "> должен существовать").ЭтоИстина();
	Ожидаем.Что(ФайлРут.ЭтоКаталог(), "<" + ПутьКФайлуРут +  "> должен быть файлом").ЭтоЛожь();

	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлуРут);
	СодержаниеРут = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	МассивСтрокРут = СтрРазделить(СодержаниеРут, ",");
	Ожидаем.Что(МассивСтрокРут.Количество(), "Некорректный формат файла root").Больше(1);

	ПутьКФайлуКорневойКонтейнер = ОбъединитьПути(КаталогИсходников, МассивСтрокРут[1]);
	ФайлКорневойКонтейнер = Новый Файл(ПутьКФайлуКорневойКонтейнер);

	Ожидаем.Что(ФайлКорневойКонтейнер.Существует(), "Файл <" + ПутьКФайлуКорневойКонтейнер +  "> должен существовать").ЭтоИстина();
	Ожидаем.Что(ФайлКорневойКонтейнер.ЭтоКаталог(), "<" + ПутьКФайлуКорневойКонтейнер +  "> должен быть файлом").ЭтоЛожь();

	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлуКорневойКонтейнер);
	СодержаниеКорневойКонтейнер = "";
	Для сч = 1 По 7 Цикл
		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
		Если ПрочитаннаяСтрока = Неопределено Тогда
			Прервать;
		КонецЕсли;

		СодержаниеКорневойКонтейнер = СодержаниеКорневойКонтейнер + ПрочитаннаяСтрока;
	КонецЦикла;
	ЧтениеТекста.Закрыть();

	МассивСтрокКорневойКонтейнер = СтрРазделить(СодержаниеКорневойКонтейнер, ",");
	Ожидаем.Что(МассивСтрокКорневойКонтейнер.Количество(), "Некорректный формат файла корневого контейнера <" + ПутьКФайлуКорневойКонтейнер + ">").Больше(3);

	ИдентификаторТипаОбъекта = СокрЛП(МассивСтрокКорневойКонтейнер[3]);
	Если Лев(ИдентификаторТипаОбъекта, 1) = "{" Тогда
		ИдентификаторТипаОбъекта = Прав(ИдентификаторТипаОбъекта, СтрДлина(ИдентификаторТипаОбъекта) - 1);
	КонецЕсли;
	Если Прав(ИдентификаторТипаОбъекта, 1) = "}" Тогда
		ИдентификаторТипаОбъекта = Лев(ИдентификаторТипаОбъекта, СтрДлина(ИдентификаторТипаОбъекта) - 1);
	КонецЕсли;

	ИдентификаторТипаОбъекта = НРег(СокрЛП(ИдентификаторТипаОбъекта));

	Если ИдентификаторТипаОбъекта = "c3831ec8-d8d5-4f93-8a22-f9bfae07327f" Тогда
		ТипФайла = "epf";
	ИначеЕсли ИдентификаторТипаОбъекта = "e41aff26-25cf-4bb6-b6c1-3f478a75f374" Тогда
		ТипФайла = "erf";
	Иначе
		ВызватьИсключение("Некорректный идентификатор типа собираемого объекта <" + ИдентификаторТипаОбъекта + ">");
	КонецЕсли;

	Возврат ТипФайла;

КонецФункции

// Функция - Получает соответствие переименований файлов обработки на основе
//			 файла renames.txt
//
// Параметры:
//  ПутьКИсходникам - Строка - Путь к папке с исходными кодами обработки
// Возвращаемое значение:
//  Соответствие - Ключ: 		оригинальный путь файла после распаковки
//				   Значение:	преобразованный путь (например, при
//								раскладывании файлов по иерархии)
//
Функция ПолучитьСоответствиеПереименований(ПутьКИсходникам)

	Переименования = Новый Соответствие;

	ФайлПереименования = Новый Файл(ОбъединитьПути(ПутьКИсходникам, "renames.txt"));

	Ожидаем.Что(ФайлПереименования.Существует(), "Файл переименования " + ФайлПереименования.ПолноеИмя + " должен существовать").ЭтоИстина();

	ЧтениеТекста = Новый ЧтениеТекста(ФайлПереименования.ПолноеИмя, КодировкаТекста.UTF8);
	СтрокаПереименования = ЧтениеТекста.ПрочитатьСтроку();
	Пока СтрокаПереименования <> Неопределено Цикл

		СтрокаПереименованияВрем = СтрокаПереименования;
		СтрокаПереименования = ЧтениеТекста.ПрочитатьСтроку();

		// Проверка на BOM?

		СписокСтрок = СтрРазделить(СтрокаПереименованияВрем, "-->");
		Если СписокСтрок.Количество() < 2 Тогда
			Продолжить;
		КонецЕсли;

		Лог.Отладка(СтрокаПереименованияВрем);

		ИсходныйПуть = СписокСтрок[0];
		ПреобразованныйПуть = СписокСтрок[1];

		Переименования.Вставить(ИсходныйПуть, ПреобразованныйПуть);

	КонецЦикла;
	ЧтениеТекста.Закрыть();

	Возврат Переименования;

КонецФункции

Процедура СобратьФайлИзИсходников(ПапкаИсходников, ИмяФайлаОбъекта)
	Лог.Информация("Собираю файл из исходников <%1> в файл %2", ПапкаИсходников, ИмяФайлаОбъекта);

	Если ИспользоватьКонфигуратор Тогда

		Конфигуратор = Новый УправлениеКонфигуратором();
		Если КонтекстКонфигуратора = Неопределено Тогда
			КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
			Конфигуратор.КаталогСборки(КаталогВременнойИБ);
		Иначе
			Конфигуратор.ИспользоватьКонтекст(КонтекстКонфигуратора);
		КонецЕсли;

		ЛогКонфигуратора = Логирование.ПолучитьЛог("oscript.lib.v8runner");
		ЛогКонфигуратора.УстановитьУровень(Лог.Уровень());

		Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
		Параметры[0] = "DESIGNER";

		КоманднаяСтрокаУпаковки = СтрШаблон("/LoadExternalDataProcessorOrReportFromFiles ""%1"" ""%2""", ПапкаИсходников, ИмяФайлаОбъекта);

		Лог.Отладка("Командная строка упаковки: " + КоманднаяСтрокаУпаковки);

		Параметры.Добавить(КоманднаяСтрокаУпаковки);

		Конфигуратор.ВыполнитьКоманду(Параметры);
		Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());
		Лог.Отладка("Очищаем каталог временной ИБ");

	Иначе

		ПутьЗапаковщика = ОбъединитьПути(КаталогПроекта(), "tools", "v8unpack");
		Если ЭтоWindows Тогда
			ПутьЗапаковщика = ПутьЗапаковщика+".exe";
		КонецЕсли;
		Ожидаем.Что(Новый Файл(ПутьЗапаковщика).Существует(), "Не найден путь к v8unpack").ЭтоИстина();

		ВременныйФайл = ВременныеФайлы.СоздатьФайл();

		КомандаЗапуска = """%1"" -B ""%2"" ""%3""";
		КомандаЗапуска = СтрШаблон(КомандаЗапуска, ПутьЗапаковщика, ПапкаИсходников, ВременныйФайл);
		Лог.Отладка(КомандаЗапуска);

		Процесс = СоздатьПроцесс(КомандаЗапуска, , Истина, , КодировкаТекста.UTF8);
		Процесс.Запустить();
		Процесс.ОжидатьЗавершения();

		ВыводПроцесса = Процесс.ПотокВывода.Прочитать();
		Ожидаем.Что(Процесс.КодВозврата, "Не удалось упаковать каталог " + ПапкаИсходников + Символы.ПС + ВыводПроцесса).Равно(0);
		Лог.Отладка(ВыводПроцесса);

		ФайлОбъекта = Новый Файл(ИмяФайлаОбъекта);
		Лог.Отладка(СтрШаблон("Перемещение из %1 в %2", ВременныйФайл, ИмяФайлаОбъекта));
		Если ФайлОбъекта.Существует() Тогда
			Лог.Отладка(СтрШаблон("Удаляю старый файл %1 ", ИмяФайлаОбъекта));
			УдалитьФайлы(ИмяФайлаОбъекта);
		КонецЕсли;

		ПереместитьФайл(ВременныйФайл, ИмяФайлаОбъекта);

	КонецЕсли;

КонецПроцедуры

Процедура КопироватьСодержимоеКаталога(Откуда, Куда)

	КаталогНазначения = Новый Файл(Куда);
	Если КаталогНазначения.Существует() Тогда
		Если КаталогНазначения.ЭтоФайл() Тогда
			УдалитьФайлы(КаталогНазначения.ПолноеИмя);
			СоздатьКаталог(Куда);
		КонецЕсли;
	Иначе
		СоздатьКаталог(Куда);
	КонецЕсли;

	Файлы = НайтиФайлы(Откуда, ПолучитьМаскуВсеФайлы());
	Для Каждого Файл Из Файлы Цикл
		ПутьКопирования = ОбъединитьПути(Куда, Файл.Имя);
		Если Файл.ЭтоКаталог() Тогда
			КопироватьСодержимоеКаталога(Файл.ПолноеИмя, ПутьКопирования);
		Иначе
			КопироватьФайл(Файл.ПолноеИмя, ПутьКопирования);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Функция ОбернутьПутьВКавычки(Знач Путь)

	Если Прав(Путь, 1) = "\" Тогда
		Путь = Лев(Путь, СтрДлина(Путь) - 1);
	КонецЕсли;

	Путь = """" + Путь + """";

	Возврат Путь;

КонецФункции

Функция УбратьКавычкиВокругПути(Знач Путь)

	Если Лев(Путь, 1) = """" Тогда
		Путь = Прав(Путь, СтрДлина(Путь) - 1);
	КонецЕсли;
	Если Прав(Путь, 1) = """" Тогда
		Путь = Лев(Путь, СтрДлина(Путь) - 1);
	КонецЕсли;

	Возврат Путь;

КонецФункции

Функция КаталогПроекта()
	ФайлИсточника = Новый Файл(ТекущийСценарий().Источник);
	Возврат ФайлИсточника.Путь;
КонецФункции

Функция ИмяСкрипта()
	ФайлИсточника = Новый Файл(ТекущийСценарий().Источник);
	Возврат ФайлИсточника.ИмяБезРасширения;
КонецФункции

Инициализация();

Если ЗапускВКоманднойСтроке() Тогда
	ЗавершитьРаботу(КодВозврата);
КонецЕсли;
