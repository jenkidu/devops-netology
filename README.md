Хост Windows 11 20H2
1. Установите средство виртуализации Oracle VirtualBox.
Установлено
---------------------------------------------------------------------------------------------------
2. Установите средство автоматизации Hashicorp Vagrant.
Установлено
---------------------------------------------------------------------------------------------------
3. Использовал PowerShell, проблем, описанных в задании не возникло.
---------------------------------------------------------------------------------------------------
4. Инициализация, редактирование конфиг-файла, команды 
up, suspend, halt отрабатываются штатно
---------------------------------------------------------------------------------------------------
5. Ресурсы выделены 1 cpu 1024 RAM
---------------------------------------------------------------------------------------------------
6. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?
Через конфигурационный файл.

 Vagrant.configure("2") do |config|
 	config.vm.box = "bento/ubuntu-20.04"
		config.vm.provider "virtualbox" do |v|
			v.memory = 2048
			v.cpus = 2
			v.name = "vaguntu"
end
 end

7. Доступ по SSH прошел норм, кстати, без обращения к документации угадал данные УЗ к виртуалке:
vagrant/vagrant
---------------------------------------------------------------------------------------------------------
8. bash man
	8.1 какой переменной можно задать длину журнала history, 
	- HISTSIZE=1000
	и на какой строчке manual это описывается?
	Создать файл в профиле .vimrc и задать настройку для показа номеров строк :setnumber
	Далее поиск
	/HISTSIZE Это строка 2140 в файле /usr/share/man/man1/bash.1.gz
	8.2 что делает директива ignoreboth в bash?
	man сообщает, что .I ignoreboth is shorthand for \fIignorespace\fP and \fIignoredups\fP.
	то есть это сокращение от директив выше. 
	ignorespace Не сохраняет команду, начинающуюся с пробела
	ignoredups Не сохраняет команду, если такая уже имеется в истории
-----------------------------------------------------------------------------------------------------------
9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?
{} - зарезервированные слова, список, в т.ч. список команд команд в отличии от "(...)" исполнятся в текущем инстансе, 
используется в различных условных циклах, условных операторах, или ограничивает тело функции, 
В командах выполняет подстановку элементов из списка. 
Если проще, то фигурные скобки, один из
Строка 530
-----------------------------------------------------------------------------------------------------------
10. Основываясь на предыдущем вопросе, как создать однократным вызовом touch 100000 файлов? 
А получилось ли создать 300000? Если нет, то почему?
Ответ: touch {000001..100000}.txt
300000 создать не получится, слишком длинный список аргументов
-----------------------------------------------------------------------------------------------------------
11. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]
[[ ]] Возвращает статус 0 или 1 в зависимости от значения указанного условного выражения
-d file - True if file exists and is a directory.
То есть указанная конструкция проверяет условие -d /tmp и возвращает значение статуса (0 или 1)
-----------------------------------------------------------------------------------------------------------
12. Основываясь на знаниях о просмотре текущих (например, PATH) и установке новых переменных; командах, которые мы рассматривали, добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке:
bash is /tmp/new_path_directory/bash
bash is /usr/local/bin/bash
bash is /bin/bash
Ответ:
1. mkdir /tmp/new_path_directory - создать папку по нужному пути
2. cp /bin/bash /tmp/new_path_directory - скопировать содержимое папку с исполняемым файлом
3. export BASH=$BASH:/tmp/new_path_directory - Создать переменную 
4. type -a bash Проверить вывод
bash is /tmp/new_path_directory/bash
bash is /usr/bin/bash
bash is /bin/bash
-------------------------------------------------------------------------------------------------------------
13. 
at - выполняется одноразово в определенное время
batch - выполняется, когда средняя загрузка падает ниже 1,5

Это конец...
