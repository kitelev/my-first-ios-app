#!/bin/bash

# Диагностический скрипт для Live Activities на реальном iPhone
# Использование: ./diagnose_live_activities.sh

set -e

echo "🔍 Диагностика Live Activities для my-first-ios-app"
echo "=================================================="
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Проверка подключенных устройств
echo "📱 Шаг 1: Проверка подключенных устройств"
echo "----------------------------------------"
DEVICES=$(xcrun xctrace list devices 2>&1 | grep -i "iPhone" | grep -v "Simulator" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ iPhone не обнаружен${NC}"
    echo "   Пожалуйста:"
    echo "   1. Подключите iPhone к компьютеру через USB"
    echo "   2. Разблокируйте iPhone"
    echo "   3. Если появится запрос 'Trust This Computer', нажмите 'Trust'"
    echo "   4. Запустите этот скрипт снова"
    exit 1
else
    echo -e "${GREEN}✅ Обнаружены устройства:${NC}"
    echo "$DEVICES"
fi

echo ""
echo "📋 Шаг 2: Сбор логов приложения"
echo "----------------------------------------"
echo "   Запускаем сбор логов в фоновом режиме..."
echo "   ${YELLOW}Пожалуйста, сейчас сделайте следующее на iPhone:${NC}"
echo ""
echo "   1. Откройте приложение my-first-ios-app"
echo "   2. Нажмите 'Start Timer'"
echo "   3. Подождите 3-5 секунд"
echo "   4. Заблокируйте экран iPhone (кнопка питания)"
echo "   5. Посмотрите на экран - есть ли виджет таймера?"
echo "   6. Разблокируйте iPhone"
echo "   7. Нажмите 'Stop Timer'"
echo "   8. Нажмите 'Send Push (works offline)'"
echo "   9. Подождите 5 секунд"
echo ""
read -p "   Нажмите Enter, когда выполните все шаги..."

# Имя устройства для логов
DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep -i "iPhone" | grep -v "Simulator" | head -1 | sed 's/ (.*//' || echo "iPhone")

echo ""
echo "   Собираем логи с устройства: $DEVICE_NAME"
echo "   (это может занять несколько секунд...)"

# Сбор логов через Console
LOG_FILE="./live_activities_diagnostics_$(date +%Y%m%d_%H%M%S).log"

# Используем xcrun для сбора логов
xcrun simctl spawn booted log show --predicate 'processImagePath contains "my-first-ios-app"' --last 2m > "$LOG_FILE" 2>&1 || {
    # Если симулятор не работает, пробуем другой метод
    echo "   Попытка альтернативного метода сбора логов..."

    # Для реального устройства используем idevicesyslog (если установлен)
    if command -v idevicesyslog &> /dev/null; then
        echo "   Используем idevicesyslog..."
        timeout 5s idevicesyslog | grep "my-first-ios-app" > "$LOG_FILE" 2>&1 || true
    else
        echo "   ${YELLOW}⚠️  idevicesyslog не установлен. Собираем доступные логи...${NC}"
        echo "   Для лучшей диагностики установите libimobiledevice:"
        echo "   brew install libimobiledevice"
        echo ""

        # Создаем пустой лог с инструкциями
        cat > "$LOG_FILE" << 'EOF'
ЛОГИ НЕ УДАЛОСЬ СОБРАТЬ АВТОМАТИЧЕСКИ

Пожалуйста, соберите логи вручную через Xcode:

1. Откройте Xcode
2. Window → Devices and Simulators (⇧⌘2)
3. Выберите ваш iPhone в левой панели
4. В нижней части окна нажмите кнопку "Open Console"
5. В строке поиска введите: my-first-ios-app
6. Выполните тест:
   - Откройте приложение на iPhone
   - Нажмите Start Timer
   - Заблокируйте экран
   - Посмотрите на экран блокировки
   - Разблокируйте и нажмите Stop Timer
7. Скопируйте все логи и пришлите их для анализа

Ищите строки с:
- 🔍 Live Activity Diagnostics
- areActivitiesEnabled
- ❌ Error starting Live Activity
EOF
    fi
}

echo -e "${GREEN}✅ Логи сохранены в: $LOG_FILE${NC}"
echo ""

# Анализ логов
echo "📊 Шаг 3: Анализ логов"
echo "----------------------------------------"

if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
    # Ищем ключевые сообщения
    echo "   Ищем диагностические сообщения..."

    if grep -q "Live Activity Diagnostics" "$LOG_FILE"; then
        echo -e "${GREEN}✅ Найдена диагностика Live Activities:${NC}"
        grep -A 10 "Live Activity Diagnostics" "$LOG_FILE" | head -20
    else
        echo -e "${YELLOW}⚠️  Диагностические сообщения не найдены${NC}"
        echo "   Это означает, что:"
        echo "   - Либо приложение не запускалось"
        echo "   - Либо логи не были собраны корректно"
    fi

    echo ""

    if grep -q "areActivitiesEnabled.*false" "$LOG_FILE"; then
        echo -e "${RED}❌ ПРОБЛЕМА: Live Activities отключены в настройках iOS!${NC}"
        echo "   Решение:"
        echo "   1. На iPhone откройте Настройки"
        echo "   2. Прокрутите вниз → my-first-ios-app"
        echo "   3. Включите переключатель 'Live Activities'"
        echo "   4. Запустите приложение снова"
    elif grep -q "areActivitiesEnabled.*true" "$LOG_FILE"; then
        echo -e "${GREEN}✅ Live Activities включены в настройках${NC}"
    fi

    echo ""

    if grep -q "Error starting Live Activity" "$LOG_FILE"; then
        echo -e "${RED}❌ ПРОБЛЕМА: Ошибка при запуске Live Activity!${NC}"
        echo "   Детали ошибки:"
        grep -A 5 "Error starting Live Activity" "$LOG_FILE"
    fi

    echo ""

    if grep -q "Live Activity started successfully" "$LOG_FILE"; then
        echo -e "${GREEN}✅ Live Activity успешно запущен!${NC}"
        grep -A 3 "Live Activity started successfully" "$LOG_FILE"
    fi
else
    echo -e "${YELLOW}⚠️  Файл логов пуст или не найден${NC}"
    echo "   Пожалуйста, соберите логи вручную (см. инструкции в файле):"
    echo "   $LOG_FILE"
fi

echo ""
echo "🔧 Шаг 4: Проверка конфигурации проекта"
echo "----------------------------------------"

# Проверка Info.plist
if grep -q "INFOPLIST_KEY_NSSupportsLiveActivities = YES" "my-first-ios-app.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✅ NSSupportsLiveActivities включен в проекте${NC}"
else
    echo -e "${RED}❌ NSSupportsLiveActivities НЕ найден!${NC}"
fi

# Проверка entitlements
if [ -f "my-first-ios-app/my-first-ios-app.entitlements" ]; then
    echo -e "${GREEN}✅ Файл entitlements существует${NC}"
    if grep -q "com.apple.security.application-groups" "my-first-ios-app/my-first-ios-app.entitlements"; then
        echo -e "${GREEN}✅ App Groups настроены${NC}"
    fi
else
    echo -e "${RED}❌ Файл entitlements не найден${NC}"
fi

# Проверка схемы сборки
if grep -q "TimerLiveActivityWidget" "my-first-ios-app.xcodeproj/xcshareddata/xcschemes/my-first-ios-app.xcscheme"; then
    echo -e "${GREEN}✅ Виджет включен в схему сборки${NC}"
else
    echo -e "${RED}❌ Виджет НЕ включен в схему сборки!${NC}"
    echo "   Это критическая проблема - виджет не будет собран!"
fi

echo ""
echo "📱 Шаг 5: Инструкции по ручной проверке"
echo "----------------------------------------"
echo ""
echo "Пожалуйста, проверьте следующее ВРУЧНУЮ на iPhone:"
echo ""
echo "1. ${BLUE}Настройки Live Activities:${NC}"
echo "   Настройки → my-first-ios-app → Live Activities = ${GREEN}ВКЛ${NC}"
echo ""
echo "2. ${BLUE}Настройки уведомлений:${NC}"
echo "   Настройки → Уведомления → my-first-ios-app:"
echo "   - Разрешить уведомления = ${GREEN}ВКЛ${NC}"
echo "   - Звуки = ${GREEN}ВКЛ${NC}"
echo "   - Баннеры = ${GREEN}ВКЛ${NC}"
echo ""
echo "3. ${BLUE}Версия iOS:${NC}"
echo "   Настройки → Основные → Об этом устройстве → Версия ПО"
echo "   Минимальная версия: ${YELLOW}iOS 16.1${NC}"
echo ""
echo "4. ${BLUE}Тест Live Activity на экране блокировки:${NC}"
echo "   - Откройте приложение"
echo "   - Нажмите 'Start Timer'"
echo "   - ${YELLOW}Заблокируйте iPhone (кнопка питания)${NC}"
echo "   - ${YELLOW}Посмотрите на экран блокировки${NC}"
echo "   - Должен появиться виджет с таймером"
echo ""
echo "5. ${BLUE}Тест Live Activity в Control Center:${NC}"
echo "   - С запущенным таймером"
echo "   - Свайп вниз от правого верхнего угла (Control Center)"
echo "   - Виджет должен быть виден там"
echo ""

echo "=================================================="
echo "✅ Диагностика завершена!"
echo ""
echo "Результаты сохранены в: $LOG_FILE"
echo ""
echo "Если проблема не решена, пожалуйста, отправьте:"
echo "  1. Файл с логами: $LOG_FILE"
echo "  2. Скриншот настроек: Настройки → my-first-ios-app"
echo "  3. Версию iOS с вашего iPhone"
echo ""
